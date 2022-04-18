#!/usr/bin/env pwsh

<#
.SYNOPSIS
Generates the finished data for the 'Breeds' table.
#>

[CmdletBinding()]
param()


$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'lib/file-utils.ps1')


Write-Host "Generating finished data for the 'Breeds' table ..."

$outputFilePath =
    Import-Mr2dxDataFileCsv IntermediateData Breeds |
    Select-Object -ExcludeProperty Initials |
    Export-Mr2dxDataFileCsv FinishedData Breeds

Write-Host "Saved 'Breeds' table data to '${outputFilePath}'."
