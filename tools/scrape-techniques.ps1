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


function Main {
    [CmdletBinding()]
    param()

    $scrapeUrl = 'https://legendcup.com/faqmr2techs.php'

    Write-Host "Scraping technique data from '${scrapeUrl}' ..."

    try {
        $response = Invoke-WebRequest $scrapeUrl
    }
    catch {
        Abort $_.Exception.Message
    }

    $techniques =
        $response.Content |
        Get-TechListFuncContent |
        Get-BreedSwitchStatementContent |
        Get-BreedCaseMatch |
        Get-BreedTechnique
    
    Write-Host "Scraped $( $techniques.Count ) technique(s)."
    
    $outputFilePath =
        $techniques | Export-Mr2dxDataFileCsv ScrapedData TechniquesLegendCup

    Write-Host "Saved scraped technique data to '${outputFilePath}'."
}


function Get-TechListFuncContent {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]
        $PageContent
    )

    $techListFuncPattern = @'
(?msx)
        ^function \s+ techList \s* \(mon\) \s* \{
            (?<Content>.+?)
        ^\}
'@
    
    $matchInfo = $PageContent | Select-String $techListFuncPattern

    if (-not $matchInfo) {
        throw 'Could not find function techList() in page content.'
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

    $matchInfo =
        $BreedSwitchStatementContent | Select-String $breedCasePattern -AllMatches
    
    if (-not $matchInfo) {
        throw 'Could not find cases in breed switch statement.'
    }

    Write-Output $matchInfo.Matches
}


function Get-BreedTechnique {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNull()]
        [System.Text.RegularExpressions.Match]
        $BreedCaseMatch
    )

    begin {
        $breedNamesToIds =
            Import-Mr2dxDataFileCsv IntermediateData Breeds |
            ConvertTo-HashTable -KeyProperty Name -ValueProperty Id
    }

    process {
        $breedName = $BreedCaseMatch.Groups['BreedName'].Value
        $breedId = $breedNamesToIds[$breedName]

        if ($null -eq $breedId) {
            throw "Error in scraped data: Unknown breed name '${breedName}'."
        }

        $techniquePattern = @'
(?x)
            \[\s*
            '(?<Range>\d)-(?<Slot>\d)',\s*
            '(?<Name>[\w -]+)',\s*
            (?<TechniqueType>\d+),\s*
            (?<GutsCost>\d+),\s*
            '(?<Force>\d*)',\s*
            '(?<HitPercent>(?:-?\d+)?)',\s*
            '(?<Withering>\d*)',\s*
            '(?<Sharpness>\d*)',\s*
            '(?<Effect>.*)',\s*
            (?<DurationHit>\d+(?:\.\d+)?),\s*
            (?<DurationMiss>\d+(?:\.\d+)?),\s*
            (?<Errantry>-?\d)\s*
            \]
'@

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
    [OutputType([PSCustomObject])]
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

    begin {
        # Fields that are converted to a type other than string.
        # Used to check if the conversion failed.
        $convertedFields = @(
            'Range', 'Slot', 'TechniqueType', 'GutsCost',
            'Force', 'HitPercent', 'Withering', 'Sharpness',
            'DurationHit', 'DurationMiss', 'Errantry'
        )
    }

    process {
        $matchGroups = $TechniqueMatch.Groups

        $technique = [PSCustomObject]@{
            BreedId       = $BreedId
            Range         = $matchGroups['Range'].Value -as [int]
            Slot          = $matchGroups['Slot'].Value -as [int]
            Name          = $matchGroups['Name'].Value
            TechniqueType = $matchGroups['TechniqueType'].Value -as [int]
            GutsCost      = $matchGroups['GutsCost'].Value -as [int]
            Force         = $matchGroups['Force'].Value -as [int]
            HitPercent    = $matchGroups['HitPercent'].Value -as [int]
            Withering     = $matchGroups['Withering'].Value -as [int]
            Sharpness     = $matchGroups['Sharpness'].Value -as [int]
            Effect        = $matchGroups['Effect'].Value
            DurationHit   = $matchGroups['DurationHit'].Value -as [float]
            DurationMiss  = $matchGroups['DurationMiss'].Value -as [float]
            Errantry      = $matchGroups['Errantry'].Value -as [int]
        }

        # A group with a null value means a type conversion above failed.
        foreach ($field in $convertedFields) {
            if ($null -eq $technique.$field) {
                throw (
                    'Error in scraped technique ' +
                    '(Breed: {0}, Range: {1}, Slot: {2}): ' +
                    "Could not parse value for field '{3}': '{4}'"
                ) -f $technique.BreedId, $technique.Range, $technique.Slot,
                     $field, $TechniqueMatch.Groups[$field].Value
            }
        }

        if ([string]::IsNullOrWhiteSpace($technique.Name)) {
            throw (
                'Error in scraped technique ' +
                '(Breed: {0}, Range: {1}, Slot: {2}): ' +
                'Name is empty.'
            ) -f $technique.BreedId, $technique.Range, $technique.Slot
        }

        Write-Output $technique
    }
}


Main
