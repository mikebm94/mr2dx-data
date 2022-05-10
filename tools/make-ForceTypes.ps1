#!/usr/bin/env pwsh

<#
.SYNOPSIS
Generates the finished data for the 'ForceTypes' table.
#>

[CmdletBinding()]
param()


$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'lib/file-utils.ps1')
. (Join-Path $PSScriptRoot 'lib/entities/ForceType.ps1')
. (Join-Path $PSScriptRoot 'lib/entities/ForceTypeIntermediate.ps1')


$TableName = 'ForceTypes'

Write-Host "Generating finished data for the '${TableName}' table ..."

$ForceTypesIntermediate =
    Import-Mr2dxDataFileCsv IntermediateData $TableName |
        ForEach-Object { [ForceTypeIntermediate]$PSItem }

$ForceTypes =
    $ForceTypesIntermediate |
        Select-Object -ExcludeProperty Flag |
        ForEach-Object { [ForceType]$PSItem }

$outputFilePath = $ForceTypes | Export-Mr2dxDataFileCsv FinishedData $TableName

Write-Host "Saved '${TableName}' table data to '${outputFilePath}'."
