#!/usr/bin/env pwsh

<#
.SYNOPSIS
Generates the finished data for the 'Breeds' table.
#>

[CmdletBinding()]
param()


$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'lib/file-utils.ps1')


$TableName = 'Breeds'

Write-Host "Generating finished data for the '${TableName}' table ..."

$outputFilePath =
    Import-Mr2dxDataFileCsv IntermediateData $TableName |
    Select-Object -ExcludeProperty Initials |
    Export-Mr2dxDataFileCsv FinishedData $TableName

Write-Host "Saved '${TableName}' table data to '${outputFilePath}'."
