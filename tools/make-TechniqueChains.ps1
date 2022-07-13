#!/usr/bin/env pwsh

using namespace System.Collections.Generic

<#
.SYNOPSIS
Generates the finished data for the 'TechniqueChains' table.

.DESCRIPTION
The 'TechniqueChains' table defines many-to-one relationships between techniques and the techniques
required to be learned and used a number of times before learning that technique.
#>

[CmdletBinding()]
param()


$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'lib/file-utils.ps1')
. (Join-Path $PSScriptRoot 'lib/entities/ErrantryTechnique.ps1')
. (Join-Path $PSScriptRoot 'lib/entities/Technique.ps1')


class TechniqueChain {
    [int] $TechniqueId

    # Used as part of the foreign keys to the Techniques table
    # to prevent chaining a technique to a technique of a different breed.
    [int] $BreedId

    [int] $RequiredTechniqueId

    [ValidateRange(1, 50)]
    [int] $RequiredTechniqueUses


    [bool] Equals([object] $obj) {
        if ($obj -isnot [TechniqueChain]) {
            return $false
        }

        $other = [TechniqueChain]$obj
        return ($this.TechniqueId -eq $other.TechniqueId)
    }

    [int] GetHashCode() {
        return $this.TechniqueId
    }
}


function Main {
    [CmdletBinding()]
    param()

    $tableName = 'TechniqueChains'

    Write-Host "Generating finished data for the '${tableName}' table ..."

    $errantryTechniques =
        Import-Mr2dxDataFileCsv ScrapedData ErrantryTechniquesLegendCup |
        ForEach-Object { [ErrantryTechniqueLegendCup]$PSItem }

    $techniqueChains = [HashSet[TechniqueChain]]::new()
    $errantryTechniques | Get-TechniqueChain | ForEach-Object {
        $techniqueChains.Add($PSItem) | Out-Null
    }

    $outputFilePath = $techniqueChains | Export-Mr2dxDataFileCsv FinishedData $tableName

    Write-Host "Saved '${tableName}' table data to '${outputFilePath}'."
}


function Get-TechniqueChain {
    [CmdletBinding()]
    [OutputType([TechniqueChain])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNull()]
        [ErrantryTechniqueLegendCup]
        $ErrantryTechnique
    )

    begin {
        $techniquesById =
            Import-Mr2dxDataFileCsv FinishedData Techniques |
            ForEach-Object { [Technique]$PSItem } |
            ConvertTo-Hashtable -KeyProperty TechniqueId
    }

    process {
        $requiredTechniqueName = $ErrantryTechnique.ChainedTechniqueName

        if (-not $requiredTechniqueName) {
            return
        }

        $techniqueId = $ErrantryTechnique.TechniqueId
        $technique = $techniquesById[$techniqueId]

        if ($null -eq $technique) {
            throw "Technique with ID '${techniqueId}' does not exist."
        }

        $breedId = $technique.BreedId
        $requiredTechnique =
            $techniquesById.Values |
            Where-Object { ($_.BreedId -eq $breedId) -and ($_.TechniqueName -eq $requiredTechniqueName) }
        
        if ($requiredTechnique -isnot [Technique]) {
            $errorMsg = "Technique with Breed ID '{1}' and name '{0}' does not exist."
            throw ($errorMsg -f $breedId, $requiredTechniqueName) 
        }

        $techniqueChain = [TechniqueChain]::new()
        $techniqueChain.TechniqueId = $techniqueId
        $techniqueChain.BreedId = $breedId
        $techniqueChain.RequiredTechniqueId = $requiredTechnique.TechniqueId
        $techniqueChain.RequiredTechniqueUses = $ErrantryTechnique.ChainedTechniqueUses

        return $techniqueChain
    }
}


Main
