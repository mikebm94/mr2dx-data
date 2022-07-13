#!/usr/bin/env pwsh

using namespace Syste.Collections.Generic

[CmdletBinding()]
param()


$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'lib/file-utils.ps1')
. (Join-Path $PSScriptRoot 'lib/entities/Baseline.ps1')


class MonsterTypeTechnique {
    [int] $MonsterTypeId

    # Used to prevent linking a monster type to a technique that isn't available for it's main breed.
    [int] $MainBreedId

    [int] $TechniqueId


    [bool] Equals([object] $obj) {
        if ($obj -isnot [MonsterTypeTechnique]) {
            return $false
        }

        $other = [MonsterTypeTechnique]$obj
        return ($this.MonsterTypeId -eq $other.MonsterTypeId -and
                $this.TechniqueId -eq $other.TechniqueId)
    }

    [int] GetHashCode() {
        return [HashCode]::Combine($this.MonsterTypeId, $this.TechniqueId)
    }
}


function Main {
    [CmdletBinding()]
    param()

    $tableName = 'MonsterTypes_Techniques'

    Write-Host "Generating finished data for the '${tableName}' table ..."

    $monsterTypeTechniques = [HashSet[MonsterTypeTechnique]]::new()

    Get-MonsterTypeBaselineTechniques | ForEach-Object {
        $monsterTypeTechniques.Add($PSItem)
    }

    Get-MonsterTypeErrantryTechniques | ForEach-Object {
        $monsterTypeTechniques.Add($PSItem)
    }

    $outputFilePath = $monsterTypeTechniques | Export-Mr2dxDataFileCsv FinishedData $tableName

    Write-Host "Saved '${tableName}' table data to '${outputFilePath}'."
}


function Get-MonsterTypeBaselineTechniques {
    [CmdletBinding()]
    [OutputType([MonsterTypeTechnique])]
    param()

    $baselinesByMonsterTypeId = [SortedList[int, Baseline]]::new()

    $monsterTypes |
}


function Get-MonsterTypeBaseline {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        $
    )
}


Main
