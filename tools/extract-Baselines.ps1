#!/usr/bin/env pwsh

using namespace System.Collections.Generic

[CmdletBinding()]
param()


$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'lib/file-utils.ps1')
. (Join-Path $PSScriptRoot 'lib/entities/Baseline.ps1')
. (Join-Path $PSScriptRoot 'lib/entities/MonsterType.ps1')
. (Join-Path $PSScriptRoot 'lib/entities/ShrineMonster.ps1')


$NonSpecialMonsterTypes =
    Import-Mr2dxDataFileCsv FinishedData MonsterTypes |
    ForEach-Object { [MonsterType]$_ } |
    Where-Object { $_.SubBreedId -ne '' }


function Main {
    [CmdletBinding()]
    param()

    $inputFilePath = (Get-ManifestFileInfo ExtractedData ShrineMonsters).FullPath

    Write-Host "Extracting monster baseline data from '${inputFilePath}' ..."

    $shrineMonsters =
        Import-Mr2dxDataFileCsv ExtractedData ShrineMonsters |
        ForEach-Object { [ShrineMonsterExtracted]$_ }

    $baselines = $shrineMonsters | Get-BaseShrineMonsters | Get-ExtractedBaseline

    if ($baselines.Count -ne $NonSpecialMonsterTypes.Count) {
        $errorMsg = 'Failed to extract baselines for some monster types. ' +
                    '(Expected: {0} baseline(s), Actual: {1} baseline(s).'
        throw ($errorMsg -f $NonSpecialMonsterTypes.Count, $baselines.Count)
    }

    Write-Host "Extracted $( $baselines.Count ) monster baseline(s)."

    $outputFilePath =
        $baselines |
        Sort-Object -Property MainBreedId, SubBreedId |
        Export-Mr2dxDataFileCsv ExtractedData Baselines

    Write-Host "Saved extracted monster baseline data to '${outputFilePath}'."
}


<#
.SYNOPSIS
Gets the shrine monsters that represent the baseline for their monster type.

.DESCRIPTION
There are 334 non-special monster types (monster types where the sub breed is one of the 38 known breeds.)
These monster types each have stats/parameters that define the baseline for monsters of that type.
Special monsters types (monster types where the sub breed is unknown) share a baseline with the pure-breed
monster type corresponding to their main breed.

The first 333 shrine monster entries represent monster type baselines. This just leaves the "Proto"
monster type (Henger/Gali). Since it wasn't actually added to the game until the DX release,
it technically doesn't have a baseline, but the first shrine monster entry with that monster type
is used as the baseline.
#>
function Get-BaseShrineMonsters {
    [CmdletBinding()]
    [OutputType([ShrineMonsterExtracted])]
    param(
        # The shrine monsters extracted from the game's data files.
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNull()]
        [ShrineMonsterExtracted[]]
        $ShrineMonsters
    )

    $Input | Where-Object { -not $_.DiffersFromBaseline }
    $Input | Where-Object { $_.MonsterTypeId -eq 71 <# "Proto" #> } | Select-Object -First 1
}


function Get-ExtractedBaseline {
    [CmdletBinding()]
    [OutputType([BaselineExtracted])]
    param(
        # A shrine monster extracted from the game's data files.
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNull()]
        [ShrineMonsterExtracted]
        $ShrineMonster
    )

    begin {
        $nonSpecialMonsterTypesById =
            $NonSpecialMonsterTypes |
            ConvertTo-Hashtable -KeyProperty MonsterTypeId
        
        $dataPoints = @(
            'Lifespan', 'Nature', 'GrowthTypeId', 'Lif', 'Pow', 'IQ', 'Ski', 'Spd', 'Def',
            'LifGainLvl', 'PowGainLvl', 'IQGainLvl', 'SkiGainLvl', 'SpdGainLvl', 'DefGainLvl',
            'ArenaSpeedLvl', 'FramesPerGut', 'BattleSpecialsBitmask', 'FortesBitmask',
            'TechniquesBitmask'
        )
    }

    process {
        $monsterType = $nonSpecialMonsterTypesById[$ShrineMonster.MonsterTypeId]

        if ($null -eq $monsterType) {
            $errorMsg = "Shrine monster (ID: {0}) is not a baseline monster (Monster Type ID: {1})."
            throw ($errorMsg -f $ShrineMonster.ShrineMonsterId, $ShrineMonster.MonsterTypeId)
        }

        $baseline = [BaselineExtracted]::new()
        $baseline.MainBreedId = $monsterType.MainBreedId
        $baseline.SubBreedId = $monsterType.SubBreedId
        
        foreach ($dataPoint in $dataPoints) {
            $baseline.$dataPoint = $ShrineMonster.$dataPoint
        }

        return $baseline
    }
}


Main
