#!/usr/bin/env pwsh

using namespace System.Collections.Generic

<#
.SYNOPSIS
Extracts raw data from the game's data files for the monsters that can be obtained at the shrine.
#>

[CmdletBinding()]
param()


$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'lib/file-utils.ps1')
. (Join-Path $PSScriptRoot 'lib/entities/MonsterType.ps1')
. (Join-Path $PSScriptRoot 'lib/entities/ShrineMonster.ps1')


function Main {
    [CmdletBinding()]
    param()

    $shrineDataFilePath = (Get-ManifestFileInfo GameFiles ShrineMonsters).FullPath

    Write-Host "Extracted shrine monster data from '${shrineDataFilePath}' ..."

    $shrineDataHeader = @(
        'ShrineMonsterId', 'ShrineMonsterName', 'MainBreedId', 'SubBreedId', 'Lifespan', 'Nature',
        'GrowthTypeId', 'Lif', 'Pow', 'IQ', 'Ski', 'Spd', 'Def', 'LifGainLvl', 'PowGainLvl', 'IQGainLvl',
        'SkiGainLvl', 'SpdGainLvl', 'DefGainLvl', 'ArenaSpeedLvl', 'FramesPerGut', 'BattleSpecialsBitmask',
        'TechniquesBitmask', 'AutoMainAlgo', 'AutoSubAlgo', 'FortesBitmask', 'TotalStats',
        'DiffersFromBaseline', 'NoOffsets'
    )

    $shrineMonsters =
        Import-Mr2dxDataFileCsv GameFiles ShrineMonsters -Header $shrineDataHeader |
        ConvertTo-ShrineMonsterExtracted
    
    $outputFilePath = $shrineMonsters | Export-Mr2dxDataFileCsv ExtractedData ShrineMonsters

    Write-Host "Saved extracted shrine monster data to '${outputFilePath}'."
}


<#
.SYNOPSIS
Converts raw data from the game's shrine monster CSV data file into `ShrineMonsterExtracted` objects.
#>
function ConvertTo-ShrineMonsterExtracted {
    [CmdletBinding()]
    [OutputType([ShrineMonsterExtracted])]
    param(
        [Parameter(Mandatory, Position = 1, ValueFromPipeline)]
        [ValidateNotNull()]
        [object]
        $InputObject
    )

    begin {
        # Map monster type IDs to hashes of their main breed ID and sub breed ID.
        $monsterTypeIdsByHash = [Dictionary[int, int]]::new()
        Import-Mr2dxDataFileCsv IntermediateData MonsterTypes | ForEach-Object {
            $monsterType = [MonsterTypeIntermediate]$PSItem
            $hash = [HashCode]::Combine($monsterType.MainBreedId, $monsterType.SubBreedId)
            $monsterTypeIdsByHash.Add($hash, $monsterType.MonsterTypeId)
        }
    }

    process {
        $monster = [ShrineMonsterExtracted]::new()

        # Get monster type ID from the hash of the input object's MainBreedId and SubBreedId.
        $mainBreedId = [int]$InputObject.MainBreedId + 1
        $subBreedId = [int]$InputObject.SubBreedId + 1
        $monsterTypeHash = [HashCode]::Combine($mainBreedId, $subBreedId)
        $monsterTypeId = $monsterTypeIdsByHash[$monsterTypeHash]

        if ($null -eq $monsterTypeId) {
            $errorMsg = "No monster type with main breed ID '{0}' and sub breed ID '{1}' exists."
            throw ($errorMsg -f $mainBreedId, $subBreedId)
        }

        $monster.MonsterTypeId = $monsterTypeId
        $monster.GrowthTypeId = [int]$InputObject.GrowthTypeId + 1
        $monster.LifGainLvl = [int]$InputObject.LifGainLvl + 1
        $monster.PowGainLvl = [int]$InputObject.PowGainLvl + 1
        $monster.IQGainLvl = [int]$InputObject.IQGainLvl + 1
        $monster.SkiGainLvl = [int]$InputObject.SkiGainLvl + 1
        $monster.SpdGainLvl = [int]$InputObject.SpdGainLvl + 1
        $monster.DefGainLvl = [int]$InputObject.DefGainLvl + 1
        $monster.ArenaSpeedLvl = [int]$InputObject.DefGainLvl + 1
        $monster.TechniquesBitmask = [Convert]::ToInt32($InputObject.TechniquesBitmask, 2)
        $monster.OffsetsApplied = ([int]$InputObject.NoOffsets -eq 0) ? 1 : 0
        
        $nonConvertedColumns = @(
            'ShrineMonsterId', 'Lifespan', 'Nature', 'Lif', 'Pow', 'IQ', 'Ski', 'Spd', 'Def',
            'FramesPerGut', 'BattleSpecialsBitmask', 'FortesBitmask', 'DiffersFromBaseline'
        )

        foreach ($column in $nonConvertedColumns) {
            $monster.$column = $InputObject.$column
        }

        return $monster
    }
}


Main
