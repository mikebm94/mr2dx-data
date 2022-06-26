#!/usr/bin/env pwsh

<#
.SYNOPSIS
Generates the finished data for the 'Baselines_Techniques' table.

.DESCRIPTION
The 'Baselines_Techniques' table is a junction/join table defining many-to-many relationships
between monster baselines and their corresponding techniques.
#>

[CmdletBinding()]
param()


$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'lib/file-utils.ps1')
. (Join-Path $PSScriptRoot 'lib/entities/Baseline.ps1')
. (Join-Path $PSScriptRoot 'lib/entities/Technique.ps1')


class BaselineTechnique {
    [int] $MainBreedId
    [int] $SubBreedId
    [int] $TechniqueId
}


function Main {
    [CmdletBinding()]
    param()

    $tableName = 'Baselines_Techniques'

    Write-Host "Generating finished data for the '${tableName}' table ..."

    $baselines =
        Import-Mr2dxDataFileCsv ExtractedData Baselines |
        ForEach-Object { [BaselineExtracted]$PSItem }
    
    $baselineTechniques = $baselines | Get-BaselineTechnique

    $outputFilePath = $baselineTechniques | Export-Mr2dxDataFileCsv FinishedData $tableName

    Write-Host "Saved '${tableName}' table data to '${outputFilePath}'."
}


function Get-BaselineTechnique {
    [CmdletBinding()]
    [OutputType([BaselineTechnique])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNull()]
        [BaselineExtracted]
        $Baseline
    )

    begin {
        $techniquesById =
            Import-Mr2dxDataFileCsv FinishedData Techniques |
            ForEach-Object { [Technique]$PSItem } |
            ConvertTo-Hashtable -KeyProperty TechniqueId
    }

    process {
        $bitmaskFlagValues = Expand-Bitmask $Baseline.TechniquesBitmask

        foreach ($flagValue in $bitmaskFlagValues) {
            $techniqueNumber = [Math]::Log2($flagValue)
            $techniqueId = [TechniqueExtracted]::GetTechniqueId($Baseline.MainBreedId, $techniqueNumber)
            $technique = $techniquesById[$techniqueId]

            if ($null -eq $technique) {
                $errorMsg = 'Monster baseline (MainBreedId: {0}, SubBreedId {1}) techniques ' +
                            "bitmask contains invalid flag value '{2}'."
                throw ($errorMsg -f $Baseline.MainBreedId, $Baseline.SubBreedId, $flagValue)
            }

            $baselineTechnique = [BaselineTechnique]::new()
            $baselineTechnique.MainBreedId = $Baseline.MainBreedId
            $baselineTechnique.SubBreedId = $Baseline.SubBreedId
            $baselineTechnique.TechniqueId = $techniqueId

            Write-Output $baselineTechnique
        }
    }
}


Main
