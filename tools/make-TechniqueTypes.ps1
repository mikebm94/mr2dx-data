#!/usr/bin/env pwsh

<#
.SYNOPSIS
Generates the finished data for the 'TechniqueTypes' table.
#>

[CmdletBinding()]
param()


$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'lib/file-utils.ps1')


Write-Host "Generating finished data for the 'TechniqueTypes' table ..."

$outputFilePath =
    Import-Mr2dxDataFileCsv IntermediateData TechniqueTypes |
    Select-Object -ExcludeProperty IdLegendCup,Flag |
    Export-Mr2dxDataFileCsv FinishedData TechniqueTypes

Write-Host "Saved 'TechniqueTypes' table data to '${outputFilePath}'."

