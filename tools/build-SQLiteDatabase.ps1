#!/usr/bin/env pwsh

[CmdletBinding()]
param()


$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'lib/file-utils.ps1')


$ScriptName = (Get-Item -Path $MyInvocation.MyCommand.Path).Name


Write-Host 'Generating MR2DX SQLite database ...'

# Build the commands to pass to the 'sqlite3' command-line utility.

$SqlScriptPath = Join-Path $SQLiteDataPath 'mr2dx-data.sql'

$CommandsSb = [Text.StringBuilder]::new()
$CommandsSb.AppendLine('.bail on') | Out-Null
$CommandsSb.AppendLine(".read '${SqlScriptPath}'").AppendLine('.echo on') | Out-Null

Get-ManifestFileInfo FinishedData | ForEach-Object {
    $tableName = $PSItem.Key
    $dataFilePath = $PSItem.FullPath
    $CommandsSb.AppendLine(".import --csv --skip 1 '${dataFilePath}' '${tableName}'") | Out-Null
}

$CommandsSb.AppendLine('.quit') | Out-Null
$Commands = $CommandsSb.ToString()

# Create the database and import the finished CSV data into the corresponding tables.

$DatabasePath = (Get-ManifestFileInfo SQLiteData SQLiteDatabase).FullPath

if (Test-Path -Path $DatabasePath -PathType Leaf) {
    Write-Host 'Deleting existing database ...'
    Remove-Item -Path $DatabasePath -Force
}

Write-Host 'Executing sqlite3 command line utility ...'

$Commands | & sqlite3 $DatabasePath 2>&1 | Tee-Object -Variable SQLiteOutput
$SQLiteExitCode = $LASTEXITCODE
$SQLiteStderr = $SQLiteOutput | Where-Object { $PSItem -is [Management.Automation.ErrorRecord] }

Write-Host "sqlite3 exited with code: ${SQLiteExitCode}"

if (($LASTEXITCODE -ne 0) -or ($null -ne $SQLiteStderr)) {
    Remove-Item -Path $DatabasePath -Force -ErrorAction Ignore
    Abort "${ScriptName}: fatal: Failed to create the SQLite database."
}

Write-Host "Saved SQLite database to '${DatabasePath}'."
