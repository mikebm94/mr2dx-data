#!/usr/bin/env pwsh

<#
.SYNOPSIS
Generates the finished data for the 'Baselines' table.
#>

[CmdletBinding()]
param()


$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'lib/file-utils.ps1')
. (Join-Path $PSScriptRoot 'lib/entities/Baseline.ps1')

$TableName = 'Baselines'


Write-Host "Generating finished data for the '${TableName}' table ..."

$BaselinesExtracted =
    Import-Mr2dxDataFileCsv ExtractedData $TableName |
    ForEach-Object { [BaselineExtracted]$_ }

$Baselines =
    $BaselinesExtracted |
    Select-Object -Property ([Baseline]::ColumnOrder) |
    ForEach-Object { [Baseline]$_ }

$OutputFilePath = $Baselines | Export-Mr2dxDataFileCsv FinishedData $TableName

Write-Host "Saved '${TableName}' table data to '${OutputFilePath}'."
