#!/usr/bin/env pwsh

using namespace System.Collections.Generic

<#
.SYNOPSIS
Generates the finished data for the 'Baselines_Fortes' table.

.DESCRIPTION
The 'Baselines_Fortes' table is a junction/join table defining many-to-many relationships
between monster baselines and their corresponding fortes.
#>

[CmdletBinding()]
param()


$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'lib/file-utils.ps1')
. (Join-Path $PSScriptRoot 'lib/entities/Baseline.ps1')
. (Join-Path $PSScriptRoot 'lib/entities/Forte.ps1')


class BaselineForte {
    [int] $MainBreedId
    [int] $SubBreedId
    [int] $ForteId
}


function Main {
    [CmdletBinding()]
    param()

    $tableName = 'Baselines_Fortes'

    Write-Host "Generating finished data for the '${tableName}' table ..."

    $baselines =
    Import-Mr2dxDataFileCsv ExtractedData Baselines |
    ForEach-Object { [BaselineExtracted]$PSItem }
    
    $baselineFortes = $baselines | Get-BaselineForte

    $outputFilePath = $baselineFortes | Export-Mr2dxDataFileCsv FinishedData $tableName

    Write-Host "Saved '${tableName}' table data to '${outputFilePath}'."
}


function Get-BaselineForte {
    [CmdletBinding()]
    [OutputType([BaselineForte])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNull()]
        [BaselineExtracted]
        $Baseline
    )

    begin {
        # Map fortes to their corresponding bitmask flag values.
        $fortesByFlagValue = [Dictionary[int, Forte]]::new()
        Import-Mr2dxDataFileCsv FinishedData Fortes | ForEach-Object {
            $forte = [Forte]$PSItem
            $flagValue = 1 -shl ($forte.ForteId - 1)
            $fortesByFlagValue.Add($flagValue, $forte)
        }
    }

    process {
        $bitmaskFlagValues = Expand-Bitmask $Baseline.FortesBitmask

        foreach ($flagValue in $bitmaskFlagValues) {
            $forte = $fortesByFlagValue[$flagValue]

            if ($null -eq $forte) {
                $errorMsg = 'Monster baseline (MainBreedId: {0}, SubBreedId {1}) fortes ' +
                "bitmask contains invalid flag value '{2}'."
                throw ($errorMsg -f $Baseline.MainBreedId, $Baseline.SubBreedId, $flagValue)
            }

            $baselineForte = [BaselineForte]::new()
            $baselineForte.MainBreedId = $Baseline.MainBreedId
            $baselineForte.SubBreedId = $Baseline.SubBreedId
            $baselineForte.ForteId = $forte.ForteId

            Write-Output $baselineForte
        }
    }
}


Main
