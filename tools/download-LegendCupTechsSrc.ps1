#!/usr/bin/env pwsh

<#
.SYNOPSIS
Downloads the JavaScript source code used in LegendCup's Errantry Calculator & Tech List page.
This source code contains data used to obtain additional data-points for techniques,
as well as data on sub-breed requirements for techniques and the requirements for learning
techniques at errantries. THANKS to everyone at LegendCup.com, including:
  ChroniusNightmare, Edzwoo, SmilingFaces96, Teawch, Tubular
#>

[CmdletBinding()]
param()


$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'lib/file-utils.ps1')

$ScriptName = (Get-Item -Path $MyInvocation.MyCommand.Path).Name
$PageUrl = 'https://legendcup.com/faqmr2techs.php'


Write-Host "Downloading Errantry Calculator & Tech List source code from '${PageUrl}' ..."

try {
    $Response = Invoke-WebRequest $PageUrl
}
catch {
    Abort "${ScriptName}: fatal: $( $PSItem.Exception.Message )"
}

$SourceCodePattern = @'
(?msx)
    ^\s* <script> \s* (
    ^\s* // .*
    ^\s* newmain\(\); .*?
    ^\s* ) </script>
'@

$MatchInfo = $Response.Content | Select-String $SourceCodePattern

if (-not $MatchInfo) {
    # TODO: Source code in page was refactored.
    throw "Could not locate errantry calculator & tech list source code in page source."
}

$OutputFilePath =
    $MatchInfo.Matches[0].Groups[1].Value |
    Set-Mr2dxDataFileContent DownloadedData LegendCupTechsSrc

Write-Host "Saved Errantry Calculator & Tech List source code to '${OutputFilePath}'."
