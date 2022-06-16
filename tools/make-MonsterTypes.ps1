#!/usr/bin/env pwsh

<#
.SYNOPSIS
Generates the finished data for the 'MonsterTypes' table.
#>

[CmdletBinding()]
param()


$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'lib/file-utils.ps1')
. (Join-Path $PSScriptRoot 'lib/entities/Breed.ps1')
. (Join-Path $PSScriptRoot 'lib/entities/MonsterType.ps1')

$TableName = 'MonsterTypes'


Write-Host "Generating finished data for the '${TableName}' table ..."

$BreedIds = 
    Import-Mr2dxDataFileCsv IntermediateData Breeds |
    ForEach-Object { [BreedIntermediate]$PSItem } |
    Select-Object -ExpandProperty BreedId

$MonsterTypesIntermediate =
    Import-Mr2dxDataFileCsv IntermediateData $TableName |
    ForEach-Object { [MonsterTypeIntermediate]$PSItem }

# Change sub-breed IDs for special monster types that don't correspond to a breed in the Breeds table
# into an empty string. This will be converted to a NULL when imported into the generated SQLite
# database and enables a foreign key constraint on the 'SubBreedId' column.
$MonsterTypes = $MonsterTypesIntermediate | ForEach-Object {
    $monsterType = [MonsterType]::new()
    $monsterType.MonsterTypeId = $PSItem.MonsterTypeId
    $monsterType.MainBreedId = $PSItem.MainBreedId
    $monsterType.SubBreedId = $PSItem.SubBreedId
    $monsterType.CardNumber = $PSItem.CardNumber
    $monsterType.MonsterTypeName = $PSItem.MonsterTypeName
    $monsterType.MonsterTypeDescription = $PSItem.MonsterTypeDescription

    if (-not $BreedIds.Contains($monsterType.SubBreedId)) {
        $monsterType.SubBreedId = ''
    }

    Write-Output $monsterType
}

$OutputFilePath =
    $MonsterTypes |
    Select-Object -Property ([MonsterType]::ColumnOrder) |
    Export-Mr2dxDataFileCsv FinishedData $TableName

Write-Host "Saved '${TableName}' table data to '${OutputFilePath}'."
