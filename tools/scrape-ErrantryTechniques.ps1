#!/usr/bin/env pwsh

<#
.SYNOPSIS
Scrapes data defining the techniques that can be learned at errantry locations and the requirements
to learn them from the JavaScript source code for LegendCup's Errantry Calculator & Tech List page.
#>

using namespace System.Collections.Generic
using namespace System.Text.RegularExpressions

[CmdletBinding()]
param()


$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'lib/file-utils.ps1')
. (Join-Path $PSScriptRoot 'lib/entities/Breed.ps1')
. (Join-Path $PSScriptRoot 'lib/entities/Technique.ps1')
. (Join-Path $PSScriptRoot 'lib/entities/ErrantryTechnique.ps1')

# Timeout regular expression searches after 5 seconds.
$MatchTimeout = [TimeSpan]::new(0, 0, 5)


function Main {
    [CmdletBinding()]
    param()

    Write-Host (
        "Scraping errantry technique data " +
        "from LegendCup Errantry Calculator & Tech List source code."
    )

    $errantryTechniques =
        Get-Mr2dxDataFileContent DownloadedData LegendCupTechsSrc |
        Get-ErrantryListFuncContent |
        Get-BreedSwitchStatementContent |
        Get-BreedErrantryTechniqueArrayItems |
        Get-ErrantryTechnique
    
    Write-Host "Scraped $( $errantryTechniques.Count ) errantry technique(s)."

    $outputFilePath =
        $errantryTechniques |
        Export-Mr2dxDataFileCsv ScrapedData ErrantryTechniquesLegendCup
    
    Write-Host "Saved scraped errantry technique data to '${outputFilePath}'."
}


<#
.SYNOPSIS
Gets the content of the errantryList() function
in the LegendCup Errantry Calculator & Tech List source code.
#>
function Get-ErrantryListFuncContent {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        # The JavaScript source code for the LegendCup Errantry Calculator & Tech List.
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]
        $SourceContent
    )

    begin {
        $pattern = '^function errantryList\(mon\) \{(?<Content>.+?)^\}$'
        $regex = [Regex]::new($pattern, "Multiline, Singleline, CultureInvariant", $MatchTimeout)
    }

    process {
        $regexMatch = $regex.Match($SourceContent)

        if (-not $regexMatch.Success) {
            throw "Failed to find errantryList() function in source code."
        }

        return $regexMatch.Groups['Content'].Value
    }
}


<#
.SYNOPSIS
Gets the content of the breed switch statement in the errantryList() function.
#>
function Get-BreedSwitchStatementContent {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        # The content of the errantryList() function.
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ErrantryListFuncContent
    )

    begin {
        $pattern = '^\s*switch \(mon\) \{(?<Content>.+?)^\s*\}$'
        $regex = [Regex]::new($pattern, "Multiline, Singleline, CultureInvariant", $MatchTimeout)
    }

    process {
        $regexMatch = $regex.Match($ErrantryListFuncContent)

        if (-not $regexMatch.Success) {
            throw "Failed to find breed switch statement in errantryList() function."
        }

        return $regexMatch.Groups['Content'].Value
    }
}


<#
.SYNOPSIS
Gets the breed names and errantry technique array items of cases in the breed switch statement.

.OUTPUTS
PSCustomObjects with the following properties:
    BreedName
        The name of the breed.
    ErrantryTechniqueItems
        An array of strings containing javascript arrays that define the breeds errantry techniques.
#>
function Get-BreedErrantryTechniqueArrayItems {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]
        $BreedSwitchStatementContent
    )

    begin {
        $pattern = @'
            ^\s+ case \s* '(?<BreedName>[A-Za-z ]+)': \s* \r?$
                \s+ req \s* = \s* (?:
                    (?: dx \s* \? \s* \[ \s* (?<ErrantryTechniques>.+?) \s* \] \s* : ) |
                    (?: \[ \s* (?<ErrantryTechniques>.+?) \s* \]; )
                )
'@

        $regex = [Regex]::new(
            $pattern,
            "Multiline, Singleline, IgnorePatternWhitespace, CultureInvariant",
            $MatchTimeout
        )
    }

    process {
        $regexMatches = $regex.Matches($BreedSwitchStatementContent)
        
        if ($regexMatches.Count -eq 0) {
            throw 'Failed to find cases in breed switch statement.'
        }
        elseif ($regexMatches.Count -lt $Breeds.Count) {
            throw 'Failed to find cases in breed switch statement for some breeds.'
        }

        foreach ($regexMatch in $regexMatches) {
            [PSCustomObject]@{
                BreedName = $regexMatch.Groups['BreedName'].Value
                ErrantryTechniqueItems = $regexMatch.Groups['ErrantryTechniques'] -split "`n"
            }
        }
    }
}


<#
.SYNOPSIS
Gets the errantry techniques parsed from items in a breeds errantry techniques javascript array.
#>
function Get-ErrantryTechnique {
    [CmdletBinding()]
    [OutputType([ErrantryTechniqueLegendCup])]
    param(
        # The name of the breed.
        [Parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $BreedName,

        # An array of strings containing javascript arrays that define the breeds errantry techniques.
        [Parameter(Mandatory, Position = 1, ValueFromPipelineByPropertyName)]
        [ValidateNotNull()]
        [string[]]
        $ErrantryTechniqueItems
    )

    begin {
        # Used to get the breed ID from the cases breed name.
        $breedNamesToIds =
            Import-Mr2dxDataFileCsv FinishedData Breeds |
            ForEach-Object { [Breed]$_ } |
            ConvertTo-HashTable -KeyProperty BreedName -ValueProperty BreedId
        
        # Used to get the technique ID from an item's BreedId and TechniqueName.
        $techniques = Import-Mr2dxDataFileCsv FinishedData Techniques
        $techniquesLookup = [SortedDictionary[string, Technique]]::new()
        foreach ($technique in $techniques) {
            $techniquesLookup.Add(
                ('{0}_{1}' -f $technique.BreedId, $technique.TechniqueName),
                [Technique]$technique
            )
        }

        $pattern = @'
            ^ \s* \[ \s*
                '(?<TechniqueRangeId>.+?)-(?<TechniqueSlot>.+?)' , \s*
                (?<ErrantryId>.+?) , \s*
                '(?<TechniqueName>.+?)' , \s*
                '(?<AutoLearnPercent>.*?)' , \s*
                (?<Lif>.+?) , \s*
                (?<Pow>.+?) , \s*
                (?<IQ>.+?) , \s*
                (?<Ski>.+?) , \s*
                (?<Spd>.+?) , \s*
                (?<Def>.+?) , \s*
                '(?<StatTotalMin>.*?)' , \s*
                '(?<StatTotalMax>.*?)' , \s*
                (?<Nature>.+?) , \s*
                '(?<ChainedTechniqueName>.*?)' , \s*
                '(?<ChainedTechniqueUses>.*?)' , \s*
                '(?<RequiredSubBreedNames>.*?)' , \s*
                '(?<LockedSubBreedNames>.*?)' , \s*
                (?<LearnPriority>.+?)
            \s* \] \s* ,? \s* \r?$
'@

        $regex = [Regex]::new($pattern, "IgnorePatternWhitespace, CultureInvariant", $MatchTimeout)

        # The names of capture groups to store the value of
        # in the corresponding field of the errantry technique entities.
        $dataPoints = @(
            'ErrantryId', 'AutoLearnPercent', 'Lif', 'Pow', 'IQ', 'Ski', 'Spd', 'Def',
            'StatTotalMin', 'StatTotalMax', 'Nature', 'ChainedTechniqueName', 'ChainedTechniqueUses',
            'RequiredSubBreedNames', 'LockedSubBreedNames', 'LearnPriority'
        )
    }

    process {
        $breedId = $breedNamesToIds[$BreedName]

        if ($null -eq $breedId) {
            throw "Breed '${BreedName}' does not exist."
        }

        foreach ($item in $ErrantryTechniqueItems) {
            $regexMatch = $regex.Match($item)

            if (-not $regexMatch.Success) {
                throw "Found malformed errantry technique array for breed '${BreedName}': ${item}"
            }

            # Get the breed's techniques matching the items TechniqueName to get the TechniqueId.
            $techName = $regexMatch.Groups['TechniqueName']
            $tech = $techniquesLookup['{0}_{1}' -f $breedId, $techName]

            if ($null -eq $tech) {
                throw "No technique named '${techName}' for breed '${BreedName}' exists."
            }

            $errantryTech = [ErrantryTechniqueLegendCup]::new()
            $errantryTech.TechniqueId = $tech.TechniqueId
            $dataPoints | ForEach-Object { $errantryTech.$_ = $regexMatch.Groups[$_].Value }

            Write-Output $errantryTech
        }
    }
}


Main
