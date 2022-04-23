#!/usr/bin/env pwsh

<#
.SYNOPSIS
Generates the finished data for the 'ForceTypes' table.
#>

[CmdletBinding()]
param()


$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'lib/file-utils.ps1')


Write-Host "Generating finished data for the 'ForceTypes' table ..."

$outputFilePath =
    Import-Mr2dxDataFileCsv IntermediateData ForceTypes |
    Select-Object -ExcludeProperty Flag |
    Export-Mr2dxDataFileCsv FinishedData ForceTypes

Write-Host "Saved 'ForceTypes' table data to '${outputFilePath}'."
