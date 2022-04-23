#!/usr/bin/env pwsh

<#
.SYNOPSIS
Generates the finished data for the 'TechniqueNatureTypes' table.
#>

[CmdletBinding()]
param()


$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'lib/file-utils.ps1')


Write-Host "Generating finished data for the 'TechniqueNatureTypes' table ..."

$outputFilePath =
    Import-Mr2dxDataFileCsv IntermediateData TechniqueNatureTypes |
    Select-Object -ExcludeProperty Flag |
    Export-Mr2dxDataFileCsv FinishedData TechniqueNatureTypes

Write-Host "Saved 'TechniqueNatureTypes' table data to '${outputFilePath}'."
