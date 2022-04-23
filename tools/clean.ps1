#!/usr/bin/env pwsh

<#
.SYNOPSIS
Cleans all generated data files.
#>

[CmdletBinding()]
param(
    # The names of the file manifests
    # for which their directory should be cleaned.
    [Parameter(Position = 0, ValueFromRemainingArguments)]
    [ValidateNotNull()]
    [string[]]
    $CleanTargets = @(
        'FinishedData', 'ExtractedData', 'ScrapedData', 'GameFiles'
    )
)


$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'lib/file-manifests.ps1')


foreach ($manifestName in $CleanTargets) {
    $manifest = $FileManifests[$manifestName]

    if ($null -eq $manifest) {
        throw "Cannot clean file manifest '${manifestName}': " +
        "Manifest does not exist."
    }

    Write-Host "Cleaning directory '$( $manifest.Directory )' ..."

    $path = (Join-Path $manifest.Directory '*')
    Remove-Item -ErrorAction Ignore -Recurse -Force -Path $path
}
