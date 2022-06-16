#!/usr/bin/env pwsh

<#
.SYNOPSIS
Generates the finished data for the 'Fortes' table.
#>

[CmdletBinding()]
param()


$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'lib/file-utils.ps1')
. (Join-Path $PSScriptRoot 'lib/entities/Forte.ps1')

$TableName = 'Fortes'


Write-Host "Generating finished data for the '${TableName}' table ..."

$FortesIntermediate =
    Import-Mr2dxDataFileCsv IntermediateData ${TableName} |
    ForEach-Object { [ForteIntermediate]$PSItem }

$Fortes =
    $FortesIntermediate |
    Select-Object -ExcludeProperty ([ForteIntermediate]::IntermediateProperties) |
    ForEach-Object { [Forte]$PSItem }

$OutputFilePath = $Fortes | Export-Mr2dxDataFileCsv FinishedData ${TableName}

Write-Host "Saved '${TableName}' table data to '${OutputFilePath}'."
