#!/usr/bin/env pwsh

<#
.SYNOPSIS
Generates the finished data for the 'TechniqueTypes' table.
#>

[CmdletBinding()]
param()


$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'lib/file-utils.ps1')
. (Join-Path $PSScriptRoot 'lib/entities/TechniqueType.ps1')

$TableName = 'TechniqueTypes'


Write-Host "Generating finished data for the '${TableName}' table ..."

$TechniqueTypesIntermediate =
    Import-Mr2dxDataFileCsv IntermediateData $TableName |
    ForEach-Object { [TechniqueTypeIntermediate]$PSItem }

$TechniqueTypes =
    $TechniqueTypesIntermediate |
    Select-Object -Property ([TechniqueType]::ColumnOrder) |
    ForEach-Object { [TechniqueType]$PSItem }

$OutputFilePath = $TechniqueTypes | Export-Mr2dxDataFileCsv FinishedData $TableName

Write-Host "Saved '${TableName}' table data to '${OutputFilePath}'."

