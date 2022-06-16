#!/usr/bin/env pwsh

<#
.SYNOPSIS
Generates the finished data for the 'BattleSpecials' table.
#>

[CmdletBinding()]
param()


$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'lib/file-utils.ps1')
. (Join-Path $PSScriptRoot 'lib/entities/BattleSpecial.ps1')

$TableName = 'BattleSpecials'


Write-Host "Generating finished data for the '${TableName}' table ..."

$BattleSpecialsIntermediate =
    Import-Mr2dxDataFileCsv IntermediateData $TableName |
    ForEach-Object { [BattleSpecialIntermediate]$PSItem }

$BattleSpecials =
    $BattleSpecialsIntermediate |
    Select-Object -ExcludeProperty Flag |
    ForEach-Object { [BattleSpecial]$PSItem }

$OutputFilePath = $BattleSpecials | Export-Mr2dxDataFileCsv FinishedData $TableName

Write-Host "Saved '${TableName}' table data to '${OutputFilePath}'."
