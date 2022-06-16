#!/usr/bin/env pwsh

<#
.SYNOPSIS
Generates the finished data for the 'TechniqueRanges' table.
#>

[CmdletBinding()]
param()


$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'lib/file-utils.ps1')
. (Join-Path $PSScriptRoot 'lib/entities/TechniqueRange.ps1')

$TableName = 'TechniqueRanges'


Write-Host "Generating finished data for the '${TableName}' table ..."

$TechniqueRangesIntermediate =
    Import-Mr2dxDataFileCsv IntermediateData $TableName |
    ForEach-Object { [TechniqueRangeIntermediate]$PSItem }

$TechniqueRanges =
    $TechniqueRangesIntermediate |
    Select-Object -ExcludeProperty ([TechniqueRangeIntermediate]::IntermediateProperties) |
    ForEach-Object { [TechniqueRange]$PSItem }

$OutputFilePath = $TechniqueRanges | Export-Mr2dxDataFileCsv FinishedData $TableName

Write-Host "Saved '${TableName}' table data to '${OutputFilePath}'."
