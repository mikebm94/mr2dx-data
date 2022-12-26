#!/usr/bin/env pwsh

<#
.SYNOPSIS
Generates the finished data for the 'TechniqueNatures' table.
#>

[CmdletBinding()]
param()


$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'lib/file-utils.ps1')
. (Join-Path $PSScriptRoot 'lib/entities/TechniqueNature.ps1')

$TableName = 'TechniqueNatures'


Write-Host "Generating finished data for the '${TableName}' table ..."

$TechniqueNaturesIntermediate =
    Import-Mr2dxDataFileCsv IntermediateData $TableName |
    ForEach-Object { [TechniqueNatureIntermediate]$PSItem }

$TechniqueNatures =
    $TechniqueNaturesIntermediate |
    Select-Object -Property ([TechniqueNature]::ColumnOrder) |
    ForEach-Object { [TechniqueNature]$PSItem }

$OutputFilePath = $TechniqueNatures | Export-Mr2dxDataFileCsv FinishedData $TableName

Write-Host "Saved '${TableName}' table data to '${OutputFilePath}'."
