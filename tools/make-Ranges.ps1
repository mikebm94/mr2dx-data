#!/usr/bin/env pwsh

<#
.SYNOPSIS
Generates the finished data for the 'Ranges' table.
#>

[CmdletBinding()]
param()


$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'lib/file-utils.ps1')


Write-Host "Generating finished data for the 'Ranges' table ..."

$outputFilePath =
    Import-Mr2dxDataFileCsv IntermediateData Ranges |
    Select-Object -ExcludeProperty IdLegendCup |
    Export-Mr2dxDataFileCsv FinishedData Ranges

Write-Host "Saved 'Ranges' table data to '${outputFilePath}'."
