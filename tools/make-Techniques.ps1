#!/usr/bin/env pwsh

<#
.SYNOPSIS
Generates the finished data for the 'Techniques' table.

.DESCRIPTION
Generates the finished data that defines the techniques available to each monster breed.

Data extracted from the game's technique data files is combined with data points
scraped from LegendCup.com that cannot be obtained from the game files.
These data paints are the English name, hit duration, miss duration,
and a description of the technique's special effect (if any).
#>

[CmdletBinding()]
param()


$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'lib/file-utils.ps1')
. (Join-Path $PSScriptRoot 'lib/entities/ForceType.ps1')
. (Join-Path $PSScriptRoot 'lib/entities/Technique.ps1')
. (Join-Path $PSScriptRoot 'lib/entities/TechniqueNature.ps1')
. (Join-Path $PSScriptRoot 'lib/entities/TechniqueRange.ps1')
. (Join-Path $PSScriptRoot 'lib/entities/TechniqueType.ps1')


$ScriptName = (Get-Item -Path $MyInvocation.MyCommand.Path).Name

# LegendCup uses different IDs for technique ranges. Use this hashtable to check that the range
# of an extracted technique is the same as the range of the corresponding scraped technique.
$TechniqueRangesLegendCup =
    Import-Mr2dxDataFileCsv IntermediateData TechniqueRanges |
    ForEach-Object { [TechniqueRangeIntermediate]$PSItem } |
    ConvertTo-Hashtable -KeyProperty IdLegendCup



function Main {
    [CmdletBinding()]
    param()

    $TableName = 'Techniques'

    Write-Host "Generating finished data for the '${TableName}' table ..."

    $extractedTechniques =
        Import-Mr2dxDataFileCsv ExtractedData Techniques |
        Sort-Object -Property { [int]$PSItem.BreedId },
                              { [int]$PSItem.TechniqueRangeId },
                              { [int]$PSItem.Slot } |
        ForEach-Object { [TechniqueExtracted]$PSItem }
    
    $scrapedTechniques =
        Import-Mr2dxDataFileCsv ScrapedData TechniquesLegendCup |
        Sort-Object -Property { [int]$PSItem.BreedId },
                              { [int]$PSItem.TechniqueRangeIdLegendCup },
                              { [int]$PSItem.Slot } |
        ForEach-Object { [TechniqueLegendCup]$PSItem }
    
    $techniques = Get-ConsolidatedTechnique $extractedTechniques $scrapedTechniques
    
    $outputFilePath =
        $techniques |
        Select-Object -Property ([Technique]::ColumnOrder) |
        Export-Mr2dxDataFileCsv FinishedData $TableName

    Write-Host "Saved '${TableName}' table data to '${outputFilePath}'."
}


<#
.SYNOPSIS
Consolidates the technique data extracted from the game's technique data files
and the data scraped from LegendCup.
#>
function Get-ConsolidatedTechnique {
    [CmdletBinding()]
    [OutputType([Technique])]
    param(
        # A collection of techniques extracted from the game's technique data files.
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNull()]
        [TechniqueExtracted[]]
        $ExtractedTechniques,

        # A collection of techniques scraped from LegendCup.
        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNull()]
        [TechniqueLegendCup[]]
        $ScrapedTechniques
    )

    if ($ExtractedTechniques.Count -ne $ScrapedTechniques.Count) {
        Abort "${ScriptName}: fatal:" `
              "Row count mismatch between extracted technique data and scraped technique data."
    }

    $flagsToTechniqueTypes =
        Import-Mr2dxDataFileCsv IntermediateData TechniqueTypes |
        ConvertTo-Hashtable -KeyProperty Flag
    
    $flagsToForceTypes =
        Import-Mr2dxDataFileCsv IntermediateData ForceTypes |
        ConvertTo-Hashtable -KeyProperty Flag

    $flagsToTechniqueNatures =
        Import-Mr2dxDataFileCsv IntermediateData TechniqueNatures |
        ConvertTo-Hashtable -KeyProperty Flag
    
    # Used to check if an extracted technique and a scraped technique
    # at the same row ID are referring to the same technique.
    $comparisons = @(
        {
            "param($a, $b)
            $a.BreedId -eq $b.BreedId"
        },
        {
            "param($a, $b)
            $a.TechniqueRangeId -eq $TechniqueRangesLegendCup[$b.TechniqueRangeIdLegendCup].Id"
        },
        {
            "param($a, $b)
            $a.Slot -eq $b.Slot"
        }
    )

    for ($i = 0; $i -lt $ExtractedTechniques.Count; $i++) {
        $extractedTech = $ExtractedTechniques[$i]
        $scrapedTech = $ScrapedTechniques[$i]
        $rowId = $i + 1

        foreach ($comparison in $comparisons) {
            if (-not (& $comparison $extractedTech $scrapedTech)) {
                Abort "${ScriptName}: fatal: Extracted technique and scraped technique" `
                      "at row ${rowId} do not refer to the same technique."
            }
        }

        $technique = [Technique]::new()
        $technique.BreedId = $extractedTech.BreedId
        $technique.TechniqueRangeId = $extractedTech.TechniqueRangeId
        $technique.Slot = $extractedTech.Slot
        $technique.Name = $scrapedTech.Name
        $technique.TechniqueTypeId = $flagsToTechniqueTypes[$extractedTech.TechniqueTypeFlag].Id
        $technique.ForceTypeId = $flagsToForceTypes[$extractedTech.ForceTypeFlag].Id
        $technique.TechniqueNatureId = $flagsToTechniqueNatures[$extractedTech.TechniqueNatureFlag].Id
        $technique.HitPercent = $extractedTech.HitPercent
        $technique.Force = $extractedTech.Force
        $technique.Withering = $extractedTech.Withering
        $technique.Sharpness = $extractedTech.Sharpness
        $technique.GutsCost = $extractedTech.GutsCost
        $technique.GutsDrain = $extractedTech.GutsDrain
        $technique.HpRecovery = $extractedTech.HpRecovery
        $technique.HpDrain = $extractedTech.HpDrain
        $technique.SelfDamageHit = $extractedTech.SelfDamageHit
        $technique.SelfDamageMiss = $extractedTech.SelfDamageMiss
        $technique.Effect = $scrapedTech.Effect
        $technique.DurationHit = $scrapedTech.DurationHit
        $technique.DurationMiss = $scrapedTech.DurationMiss

        Write-Output $technique
    }
}


Main
