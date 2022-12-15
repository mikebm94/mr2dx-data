#!/usr/bin/env pwsh

<#
.SYNOPSIS
Scrape breed technique data from legendcup.com to supplement data
extracted from the game files.

.DESCRIPTION
The breed technique data is scraped from https://legendcup.com/faqmr2techs.php
and is used to supplement the technique data extracted from the game files
with the English names for techniques as well as the hit/miss durations.
#>

[CmdletBinding()]
param()


$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'lib/file-utils.ps1')
. (Join-Path $PSScriptRoot 'lib/entities/Breed.ps1')
. (Join-Path $PSScriptRoot 'lib/entities/Technique.ps1')

$ScriptName = (Get-Item -Path $MyInvocation.MyCommand.Path).Name


function Main {
    [CmdletBinding()]
    param()

    Write-Host "Scraping technique data from LegendCup Errantry Calculator & Tech List source code ..."

    $techniques =
        Get-Mr2dxDataFileContent DownloadedData LegendCupTechsSrc |
        Get-TechListFuncContent |
        Get-BreedSwitchStatementContent |
        Get-BreedCaseMatch |
        Get-BreedTechnique
    
    Write-Host "Scraped $( $techniques.Count ) technique(s)."
    
    $outputFilePath = $techniques | Export-Mr2dxDataFileCsv ScrapedData TechniquesLegendCup

    Write-Host "Saved scraped technique data to '${outputFilePath}'."
}


function Get-TechListFuncContent {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]
        $SourceContent
    )

    $techListFuncPattern = @'
(?msx)
        ^function \s+ techList \s* \(mon\) \s* \{
            (?<Content>.+?)
        ^\}
'@
    
    $matchInfo = $SourceContent | Select-String $techListFuncPattern

    if (-not $matchInfo) {
        throw 'Could not find function techList() in source code.'
    }

    Write-Output $matchInfo.Matches[0].Groups['Content'].Value
}


function Get-BreedSwitchStatementContent {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]
        $TechListFuncContent
    )

    $breedSwitchPattern = @'
(?msx)
        ^\s+ switch \s* \(mon\) \s* \{
            (?<Content>.+?)
        ^\s+ \}
'@

    $matchInfo = $TechListFuncContent | Select-String $breedSwitchPattern

    if (-not $matchInfo) {
        throw 'Could not find breed switch statement in function techList()'
    }

    Write-Output $matchInfo.Matches[0].Groups['Content'].Value
}


function Get-BreedCaseMatch {
    [CmdletBinding()]
    [OutputType([System.Text.RegularExpressions.Match])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]
        $BreedSwitchStatementContent
    )

    $breedCasePattern = @'
(?msx)
        ^\s+ case \s* '(?<BreedName>[A-Za-z ]+)': \s* \r?$
            \s+ tec \s* = \s* (?:
                (?: dx \s* \? \s* \[ (?<Techniques>.+?) \] \s* : ) |
                (?: \[ (?<Techniques>.+?) \]; )
            )
'@

    $matchInfo = $BreedSwitchStatementContent | Select-String $breedCasePattern -AllMatches
    
    if (-not $matchInfo) {
        throw 'Could not find cases in breed switch statement.'
    }

    Write-Output $matchInfo.Matches
}


function Get-BreedTechnique {
    [CmdletBinding()]
    [OutputType([TechniqueLegendCup])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNull()]
        [System.Text.RegularExpressions.Match]
        $BreedCaseMatch
    )

    begin {
        $breedNamesToIds =
            Import-Mr2dxDataFileCsv FinishedData Breeds |
            ForEach-Object { [Breed]$PSItem } |
            ConvertTo-HashTable -KeyProperty BreedName -ValueProperty BreedId
        
        $fieldPatterns = (
            "'(?<TechniqueRangeId>\d)-(?<Slot>\d)'",
            "'(?<TechniqueName>[\w -]+)'",
            "(?<TechniqueTypeIdLegendCup>\d+)",
            "(?<GutsCost>\d+)",
            "'(?<Damage>\d*)'",
            "'(?<HitPercent>(?:-?\d+)?)'",
            "'(?<Withering>\d*)'",
            "'(?<Sharpness>\d*)'",
            "'(?<Effect>.*)'",
            "(?<DurationHit>\d+(?:\.\d+)?)",
            "(?<DurationMiss>\d+(?:\.\d+)?)",
            "(?<Errantry>-?\d)"
        )

        $techniquePattern = '(?x) \[ \s*'
        
        for ($i = 0; $i -lt $fieldPatterns.Count; $i++) {
            $techniquePattern += @"
                (?: dx \s* \? \s* $( $fieldPatterns[$i] ) \s* : \s* .+?
                  | $( $fieldPatterns[$i] ) )
"@
            $isLastField = ($i -eq ($fieldPatterns.Count - 1))
            $techniquePattern += $isLastField ? '\s* \]' : '\s* , \s*'
        }
    }

    process {
        $breedName = $BreedCaseMatch.Groups['BreedName'].Value
        $breedId = $breedNamesToIds[$breedName]

        if ($null -eq $breedId) {
            Abort "${ScriptName}: fatal: Error in scraped data: Unknown breed name '${breedName}'."
        }

        $matchInfo =
            $BreedCaseMatch.Groups['Techniques'].Value |
            Select-String $techniquePattern -AllMatches
        
        if (-not $matchInfo) {
            throw "Could not find techniques for breed '${breedName}'."
        }

        $matchInfo.Matches | Get-ParsedTechnique $breedId
    }
}

function Get-ParsedTechnique {
    [CmdletBinding()]
    [OutputType([TechniqueLegendCup])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNull()]
        [System.Text.RegularExpressions.Match]
        $TechniqueMatch,

        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNull()]
        [int]
        $BreedId
    )

    process {
        $technique = [TechniqueLegendCup]::new()
        $technique.BreedId = $BreedId

        # Populate the scraped techniques values using the values
        # of the capture groups with the same name.
        foreach ($matchGroup in $TechniqueMatch.Groups) {
            # Skip the automatic group containing the entire match.
            if ($matchGroup.Name -eq '0') {
                continue
            }

            $fieldName = $matchGroup.Name
            $technique.$fieldName = $matchGroup.Value
        }

        Write-Output $technique
    }
}


Main
