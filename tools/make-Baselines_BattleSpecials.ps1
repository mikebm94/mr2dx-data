#!/usr/bin/env pwsh

using namespace System.Collections.Generic

<#
.SYNOPSIS
Generates the finished data for the 'Baselines_BattleSpecials' table.

.DESCRIPTION
The 'Baselines_BattleSpecials' table is a junction/join table defining many-to-many relationships
between monster baselines and their corresponding battle specials.
#>

[CmdletBinding()]
param()


$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'lib/file-utils.ps1')
. (Join-Path $PSScriptRoot 'lib/entities/Baseline.ps1')
. (Join-Path $PSScriptRoot 'lib/entities/BattleSpecial.ps1')


class BaselineBattleSpecial {
    [int] $MainBreedId
    [int] $SubBreedId
    [int] $BattleSpecialId
}


function Main {
    [CmdletBinding()]
    param()

    $tableName = 'Baselines_BattleSpecials'

    Write-Host "Generating finished data for the '${tableName}' table ..."

    $baselines =
        Import-Mr2dxDataFileCsv ExtractedData Baselines |
        ForEach-Object { [BaselineExtracted]$PSItem }
    
    $baselineBattleSpecials = $baselines | Get-BaselineBattleSpecial

    $outputFilePath = $baselineBattleSpecials | Export-Mr2dxDataFileCsv FinishedData $tableName

    Write-Host "Saved '${tableName}' table data to '${outputFilePath}'."
}


function Get-BaselineBattleSpecial {
    [CmdletBinding()]
    [OutputType([BaselineBattleSpecial])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNull()]
        [BaselineExtracted]
        $Baseline
    )

    begin {
        # Map battle specials to their corresponding bitmask flag values.
        $battleSpecialsByFlagValue = [Dictionary[int, BattleSpecial]]::new()
        Import-Mr2dxDataFileCsv FinishedData BattleSpecials | ForEach-Object {
            $battleSpecial = [BattleSpecial]$PSItem
            $flagValue = 1 -shl ($battleSpecial.BattleSpecialId - 1)
            $battleSpecialsByFlagValue.Add($flagValue, $battleSpecial)
        }
    }

    process {
        $bitmaskFlagValues = Expand-Bitmask $Baseline.BattleSpecialsBitmask

        foreach ($flagValue in $bitmaskFlagValues) {
            $battleSpecial = $battleSpecialsByFlagValue[$flagValue]

            if ($null -eq $battleSpecial) {
                $errorMsg = 'Monster baseline (MainBreedId: {0}, SubBreedId {1}) battle specials ' +
                            "bitmask contains invalid flag value '{2}'."
                throw ($errorMsg -f $Baseline.MainBreedId, $Baseline.SubBreedId, $flagValue)
            }

            $baselineBattleSpecial = [BaselineBattleSpecial]::new()
            $baselineBattleSpecial.MainBreedId = $Baseline.MainBreedId
            $baselineBattleSpecial.SubBreedId = $Baseline.SubBreedId
            $baselineBattleSpecial.BattleSpecialId = $battleSpecial.BattleSpecialId

            Write-Output $baselineBattleSpecial
        }
    }
}


Main
