#!/usr/bin/env pwsh

<#
.SYNOPSIS
Cleans all generated data files.
#>

[CmdletBinding()]
param(
    # The names of the file manifests for which their directory should be cleaned.
    [Parameter(Position = 0, ValueFromRemainingArguments)]
    [ValidateNotNull()]
    [ValidateSet('SQLiteData', 'FinishedData', 'ExtractedData', 'ScrapedData', 'GameFiles')]
    [string[]]
    $CleanTargets = @( 'SQLiteData', 'FinishedData', 'ExtractedData', 'ScrapedData', 'GameFiles' )
)


$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'lib/file-utils.ps1')


$CleanTargets | Get-ManifestFileInfo | ForEach-Object {
    if (Test-Path -LiteralPath $PSItem.FullPath) {
        Remove-Item -LiteralPath $PSItem.FullPath -Force -ErrorAction Continue
    }
}
