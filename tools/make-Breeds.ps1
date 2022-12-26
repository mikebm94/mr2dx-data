#!/usr/bin/env pwsh

<#
.SYNOPSIS
Generates the finished data for the 'Breeds' table.
#>

[CmdletBinding()]
param()


$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'lib/file-utils.ps1')
. (Join-Path $PSScriptRoot 'lib/entities/Breed.ps1')

$TableName = 'Breeds'


Write-Host "Generating finished data for the '${TableName}' table ..."

$BreedsIntermediate =
    Import-Mr2dxDataFileCsv IntermediateData $TableName |
    ForEach-Object { [BreedIntermediate]$PSItem }

$Breeds =
    $BreedsIntermediate |
    Select-Object -Property ([Breed]::ColumnOrder) |
    ForEach-Object { [Breed]$PSItem }

$OutputFilePath = $Breeds | Export-Mr2dxDataFileCsv FinishedData $TableName

Write-Host "Saved '${TableName}' table data to '${OutputFilePath}'."
