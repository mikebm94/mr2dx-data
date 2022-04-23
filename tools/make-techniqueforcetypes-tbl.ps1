#!/usr/bin/env pwsh

<#
.SYNOPSIS
Generates the finished data for the 'TechniqueForceTypes' table.
#>

[CmdletBinding()]
param()


$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'lib/file-utils.ps1')


Write-Host "Generating finished data for the 'TechniqueForceTypes' table ..."

$outputFilePath =
Import-Mr2dxDataFileCsv IntermediateData TechniqueForceTypes |
Select-Object -ExcludeProperty Flag |
Export-Mr2dxDataFileCsv FinishedData TechniqueForceTypes

Write-Host "Saved 'TechniqueForceTypes' table data to '${outputFilePath}'."
