#!/usr/bin/env pwsh

<#
.SYNOPSIS
Extracts the archive containing the MR2DX game data files.

.DESCRIPTION
The `ArchivePath` parameter or MR2DX_ARCHIVE_PATH environment variable
can be set to specify an explicit path to the game data archive.
If neither are not set or the path does not exist, then the Steam library
is searched for an MR2DX installation to obtain a path to the archive.

If no Steam library path is given using the `SteamLibraryPath` parameter
or MR2DX_STEAMLIB_PATH environment variable, then the default Steam library
path for your platform will be used.

The '7z', '7zz', or '7zzs' command (7-Zip) must be installed to extract
the archive. On Windows, the command does not have to be in PATH because
the registry can be searched for the 7-Zip installation location. On Linux
and macOS, 7-Zip can be provided by p7zip (the 'p7zip-full' package
or equivalent package for your distribution) or by the official
7-Zip for linux.

The files that will be extracted from the archive are listed in the
'game-files-manifest.txt' file, or to extract all files from the archive,
use the `ExtractAllFiles` switch.

These files are only needed if you plan to further develop mr2dx-data
(e.g. adding additional game data to the database, or changing the way
that it is extracted), or if the game data is changed by an update
to MR2DX. The database can be (re)built and the schema can be changed
without them.

.EXAMPLE
PS> .\extract-game-archive.ps1 -SteamLibraryPath D:\MySteamLibrary

.EXAMPLE
PS> ./extract-game-archive.ps1 -DestinationPath ~/Documents/MR2-game-files
#>

[CmdletBinding()]
param(
    # The directory to place the files extracted from the archive. It will
    # be created if it does not exist.
    #
    # If this parameter is not specified, it will be set to the value of the
    # MR2DX_GAMEDATA_PATH environment variable if it is set. Otherwise,
    # defaults to the directory 'gamedata' in the repository root.
    [Parameter(Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]
    $DestinationPath =
        [Environment]::GetEnvironmentVariable('MR2DX_GAMEDATA_PATH'),

    # The path to the Steam library directory that MR2DX is installed to
    # which contains the 'steamapps' subdirectory. Used to locate the
    # game data archive.
    #
    # If this parameter is not specified, it will be set to the value of the
    # MR2DX_STEAMLIB_PATH environment variable if it is set. Otherwise,
    # the default Steam library path for your platform is used:
    #  - Windows : C:\Program Files (x86)\Steam\
    #  - MacOS   : ~/Library/Application Support/Steam/
    #  - Linux   : ~/.steam/steam/
    [ValidateNotNullOrEmpty()]
    [string]
    $SteamLibraryPath =
        [Environment]::GetEnvironmentVariable('MR2DX_STEAMLIB_PATH'),

    # The path to the game data archive to extract.
    # Useful on macOS to use a copy of the archive obtained from another
    # computer or OS since MR2DX cannot be installed on macOS.
    #
    # If this parameter is not specified, it will be set to the value of the
    # MR2DX_ARCHIVE_PATH environment variable if it is set.
    #
    # If the archive path is not set or does not exist, then the Steam
    # library will be searched for an MR2DX installation to obtain a path
    # to the game data archive.
    [ValidateNotNullOrEmpty()]
    [string]
    $ArchivePath = [Environment]::GetEnvironmentVariable('MR2DX_ARCHIVE_PATH'),

    # By default, only the files currently used to develop the database are
    # extracted. Use this switch to extract them all.
    [Alias('All')]
    [switch]
    $ExtractAllFiles,

    # Specifies whether to overwrite files that already exist in the
    # destination path.
    #
    # Always : Overwrite the existing file without confirmation.
    # Prompt : Ask before overwriting the existing file.
    # Never  : Skip the extraction of the file.
    [ValidateSet('Always', 'Prompt', 'Never')]
    [string]
    $OverwriteMode = 'Always'
)


$GameArchivePassword = 'KoeiTecmoMF1&2'
$GameFilesManifestPath = Join-Path $PSScriptRoot '../game-files-manifest.txt'


function Main {
    $ErrorActionPreference = 'Stop'

    if (-not $DestinationPath) {
        $DestinationPath = Join-Path $PSScriptRoot '../gamedata'
    }

    $gameArchivePath = Get-GameArchivePath

    if (-not $gameArchivePath) {
        throw "Failed to find the MR2DX game data archive."
    }

    Write-Host "Extracting MR2DX game data archive at '${gameArchivePath}'..."

    Expand-ArchiveWith7z $gameArchivePath

    if (-not (Test-Path $DestinationPath -PathType Container)) {
        throw "Failed to extract MR2DX game data files to '${DestinationPath}'"
    }

    Write-Host "Extracted MR2DX game data files to" `
               "'$(Resolve-Path $DestinationPath)'."
}


function Get-GameArchivePath {
    if ($ArchivePath) {
        if (Test-Path $ArchivePath -PathType Leaf) {
            return $ArchivePath
        }
        else {
            Write-Host "Game archive path '${ArchivePath}' does not exist."
        }
    }

    return Find-GameArchiveInSteamLibrary
}


function Find-GameArchiveInSteamLibrary {
    if (-not $SteamLibraryPath) {
        $SteamLibraryPath = Get-DefaultSteamLibraryPath
    }

    Write-Host "Searching for game archive in Steam library" `
               "at '${SteamLibraryPath}'..."

    if (-not (Test-Path $SteamLibraryPath -PathType Container)) {
        Write-Host "The Steam library path '${SteamLibraryPath}' does not exist."
        return $null
    }
    
    $gamesInstallPath =
        Join-Path (Resolve-Path $SteamLibraryPath) 'steamapps/common/'
    
    if (-not (Test-Path $gamesInstallPath -PathType Container)) {
        Write-Host "The path '${SteamLibraryPath}' is not a valid Steam library."
        return $null
    }

    $mr2dxInstallPath = Join-Path $gamesInstallPath 'mfdx/MF2/'

    if (-not (Test-Path $mr2dxInstallPath -PathType Container)) {
        Write-Host "No MR2DX installation found in Steam library" `
                   "at '${SteamLibraryPath}'."
        return $null
    }

    $gameArchivePath = Join-Path $mr2dxInstallPath 'Resources/data/data.bin'

    if (-not (Test-Path $gameArchivePath -PathType Leaf)) {
        Write-Host "An MR2DX installation was found," `
                   "but the archive '${gameArchivePath}' is missing."
        return $null
    }

    return $gameArchivePath
}


function Get-DefaultSteamLibraryPath {
    if ($IsLinux) {
        return "~/.steam/steam"
    }
    elseif ($IsMacOS) {
        return "~/Library/Application Support/Steam"
    }

    # Windows
    return "C:\Program Files (x86)\Steam"
}


function Expand-ArchiveWith7z {
    param(
        [Parameter(Position = 0, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $GameArchivePath
    )

    $7z = Get-7zipCommandPath

    if (-not $7z) {
        throw "Failed to find the '7z', '7zz', or '7zzs' command." +
              "Please install 7-Zip."
    }

    Write-Host "Found 7-Zip command line utility: ${7z}"

    $7zArgs = @(
        'x', # Extract command
        "-p${GameArchivePassword}"
        "-o${DestinationPath}"
    )

    switch ($OverwriteMode) {
        'Always' { $7zArgs += '-aoa' }
        'Never'  { $7zArgs += '-aos' }
    }

    $7zArgs += $GameArchivePath

    if (-not $ExtractAllFiles) {
        $7zArgs += "@${GameFilesManifestPath}"
    }

    & $7z @7zArgs
    $7zExitCode = $LASTEXITCODE

    Write-Host @"
7-Zip exited with code: ${7zExitCode}
NOTE: A non-zero exit code doesn't mean the extraction failed.
      The MR2DX game archive is badly-formed but is correctly extracted
      by 7-Zip, which can/will exit with a fatal error (code 2)
      even when the extraction succeeded.
"@
}


function Get-7zipCommandPath {
    # Check if the 7-Zip command-line utility is in PATH.
    foreach ($cmdName in '7z','7zzs','7zz') {
        $7zAppInfo = Get-Command $cmdName -CommandType App -ErrorAction Ignore

        if ($null -ne $7zAppInfo) {
            return $7zAppInfo[0].Path
        }
    }

    if (-not $IsWindows) {
        return $null
    }

    # Check Windows registry for path to 7-Zip installation.
    foreach ($rootKey in 'HKEY_CURRENT_USER', 'HKEY_LOCAL_MACHINE') {
        $regValues = @()

        if ([Environment]::Is64BitOperatingSystem) {
            $regValues += 'Path64'
        }

        $regValues += 'Path'
        $7zRegKey = Get-Item "Registry::\$rootKey\SOFTWARE\7-Zip\"

        if ($null -eq $7zRegKey) {
            continue
        }

        foreach ($regValue in $regValues) {
            $7zInstallPath = $7zRegKey.GetValue($regValue)

            if ($null -eq $7zInstallPath) {
                continue
            }
            
            $7zPath = Join-Path $7zInstallPath '7z.exe'

            if (Test-Path $7zPath -PathType Leaf) {
                return $7zPath
            }
        }
    }

    return $null
}


Main
