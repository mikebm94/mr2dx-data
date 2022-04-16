#!/usr/bin/env pwsh

<#
.SYNOPSIS
Cleans all generated data files.
#>

[CmdletBinding()]
param()


$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'lib/paths.ps1')


$DirectoriesToClean = @(
    $FinishedDataPath,
    $ImageDataPath,
    $ExtractedIntermediateDataPath,
    $ScrapedIntermediateDataPath,
    $GameFilesPath
)


foreach ($path in $DirectoriesToClean) {
    Remove-Item -ErrorAction Ignore -Recurse -Force -Path (Join-Path $path '*')
}
