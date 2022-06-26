#!/usr/bin/env pwsh

using namespace System.Collections.Generic

<#
.SYNOPSIS
Generates the finished data for the 'MonsterTypes_Baselines' table.

.DESCRIPTION
The 'MonsterTypes_Baselines' table is a junction/join table defining relationships
between monster types and their corresponding baselines. Every non-special monster type (monster types
with a known sub breed) has it's own baseline. Special monster types (monster types with an unknown
sub breed) share a baseline with the pure-breed monster type corresponding to their main breed.
#>

[CmdletBinding()]
param()


$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'lib/file-utils.ps1')
. (Join-Path $PSScriptRoot 'lib/entities/Baseline.ps1')
. (Join-Path $PSScriptRoot 'lib/entities/MonsterType.ps1')


class MonsterTypeBaseline {
    [int] $MonsterTypeId
    [int] $MainBreedId
    [int] $SubBreedId
}


function Main {
    [CmdletBinding()]
    param()

    $tableName = 'MonsterTypes_Baselines'

    Write-Host "Generating finished data for the '${tableName}' table ..."

    $monsterTypes =
        Import-Mr2dxDataFileCsv FinishedData MonsterTypes |
        ForEach-Object { [MonsterType]$PSItem }
    
    $monsterTypeBaselines = $monsterTypes | Get-MonsterTypeBaseline

    $outputFilePath = $monsterTypeBaselines | Export-Mr2dxDataFileCsv FinishedData $tableName

    Write-Host "Saved '${tableName}' table data to '${outputFilePath}'."
}


function Get-MonsterTypeBaseline {
    [CmdletBinding()]
    [OutputType([MonsterTypeBaseline])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNull()]
        [MonsterType]
        $MonsterType
    )

    begin {
        # Map baselines to a hash code generated from their main breed and sub breed.
        $baselinesByHash = [SortedList[int, Baseline]]::new()
        Import-Mr2dxDataFileCsv FinishedData Baselines | ForEach-Object {
            $baseline = [Baseline]$PSItem
            $baselineHash = [HashCode]::Combine($baseline.MainBreedId, $baseline.SubBreedId)
            $baselinesByHash.Add($baselineHash, $baseline)
        }
    }

    process {
        $baselineMainBreedId = $MonsterType.MainBreedId
        $baselineSubBreedId =
            ($MonsterType.SubBreedId -eq '') ? $MonsterType.MainBreedId : [int]$MonsterType.SubBreedId

        $baselineHash = [HashCode]::Combine($baselineMainBreedId, $baselineSubBreedId)
        $baseline = $baselinesByHash[$baselineHash]

        if ($null -eq $baseline) {
            throw "No suitable baseline exists for monster type '$( $MonsterType.MonsterTypeName )'."
        }

        $monsterTypeBaseline = [MonsterTypeBaseline]::new()
        $monsterTypeBaseline.MonsterTypeId = $MonsterType.MonsterTypeId
        $monsterTypeBaseline.MainBreedId = $baseline.MainBreedId
        $monsterTypeBaseline.SubBreedId = $baseline.SubBreedId

        return $monsterTypeBaseline
    }
}


Main
