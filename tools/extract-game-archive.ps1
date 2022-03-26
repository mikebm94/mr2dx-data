#!/usr/bin/env pwsh

<#
.SYNOPSIS
Locates and extracts the archive containing the MR2DX data files.

.DESCRIPTION
Searches a Steam library for an MR2DX installation at
'{SteamLibraryPath}/steamapps/common/mfdx/MF2/', and extracts the game data
archive at '{mr2dxInstallPath}/Resources/data/data.bin'.

If no Steam library path is given using the `SteamLibraryPath` parameter,
the default Steam library path for your platform will be used.

The '7z' command (7-Zip) must be installed to extract the archive.
On Windows, the command doesn't have to be in PATH because the registry
can be searched for the 7-Zip installation location. On Linux and macOS,
the '7z' command can be provided by p7zip (the 'p7zip-full' package
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

[CmdletBinding(DefaultParameterSetName = 'FindArchive')]
param(
    # The directory to place the files extracted from the archive. It will
    # be created if it doesn't exist.
    #
    # If this parameter isn't specified, it will be set to the value of the
    # MR2DX_GAMEDATA_PATH environment variable if it is set. Otherwise,
    # defaults to the directory 'gamedata' in the repository root.
    [Parameter(Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]
    $DestinationPath,

    # The path to the Steam library directory that MR2DX is installed to
    # which contains the 'steamapps' subdirectory. Used to loacate the
    # game data archive.
    #
    # Default:
    #  - Windows : C:\Program Files (x86)\Steam\
    #  - MacOS   : ~/Library/Application Support/Steam/
    #  - Linux   : ~/.steam/steam/
    [Parameter(ParameterSetName = 'FindArchive')]
    [ValidateNotNullOrEmpty()]
    [string]
    $SteamLibraryPath,

    # The path to the game data archive to extract.
    # Useful on macOS to use a copy of the archive obtained from another computer
    # or OS since MR2DX can't be installed on macOS.
    [Parameter(ParameterSetName = 'ExplicitArchivePath', Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]
    $ArchivePath,

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
    [CmdletBinding()]
    param()

    $ErrorActionPreference = 'Stop'

    # If parameter DestinationPath isn't set, set to MR2DX_GAMEDATA_PATH
    # environment variable or 'gamedata/'.
    if ([string]::IsNullOrEmpty($DestinationPath)) {
        $DestinationPath =
            [Environment]::GetEnvironmentVariable('MR2DX_GAMEDATA_PATH')

        if ([string]::IsNullOrEmpty($DestinationPath)) {
            $DestinationPath = Join-Path $PSScriptRoot '../gamedata'
        }
    }

    if (-not [string]::IsNullOrEmpty($ArchivePath)) {
        if (-not (Test-Path $ArchivePath -PathType Leaf)) {
            throw "The game archive '${ArchivePath}' does not exist."
        }

        $gameArchivePath = $ArchivePath
    }
    elseif ([string]::IsNullOrEmpty($SteamLibraryPath)) {
        if ($IsLinux) {
            $SteamLibraryPath = Join-Path $HOME '.steam/steam/'
        }
        elseif ($IsMacOS) {
            $SteamLibraryPath =
                Join-Path $HOME 'Library/Application Support/Steam/'
        }
        else { # Windows
            $SteamLibraryPath = 'C:\Program Files (x86)\Steam\'
        }

        Write-Host "Using default Steam library: ${SteamLibraryPath}"
        $gameArchivePath = Get-GameArchivePath
    }

    Expand-ArchiveWith7z $gameArchivePath
    Write-Host "Extracted MR2DX game data files to: $(Resolve-Path $DestinationPath)"
}


<#
.SYNOPSIS
Gets the path to the archive containing MR2DX game data files.

.OUTPUTS
The absolute path to the MR2DX 'data.bin' archive.
#>
function Get-GameArchivePath {
    [CmdletBinding()]
    [OutputType([string])]
    param()

    if (-not (Test-Path $SteamLibraryPath -PathType Container)) {
        throw "The Steam library path '${SteamLibraryPath}' does not exist."
    }
    
    $gamesInstallPath =
        Join-Path (Resolve-Path $SteamLibraryPath) 'steamapps/common/'
    
    if (-not (Test-Path $gamesInstallPath -PathType Container)) {
        throw "The path '${SteamLibraryPath}' is not a valid Steam library."
    }

    $mr2dxInstallPath = Join-Path $gamesInstallPath 'mfdx/MF2/'

    if (-not (Test-Path $mr2dxInstallPath -PathType Container)) {
        throw "No MR2DX installation found in Steam library " +
              "at '${SteamLibraryPath}'."
    }

    $gameArchivePath = Join-Path $mr2dxInstallPath 'Resources/data/data.bin'

    if (-not (Test-Path $gameArchivePath -PathType Leaf)) {
        throw "An MR2DX installation was found, " +
              "but the archive '${gameArchivePath}' is missing."
    }

    return $gameArchivePath
}


<#
.SYNOPSIS
Extracts the archive containing MR2DX game data files
to the destination path using the 7-Zip command-line utility.
#>
function Expand-ArchiveWith7z {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $GameArchivePath
    )

    $7z = Get-7zipCommandPath

    if ([string]::IsNullOrEmpty($7z)) {
        throw "Failed to find the '7z', '7zz', or '7zzs' command. " +
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


<#
.SYNOPSIS
Checks the PATH and registry for the 7-Zip command-line utility.

.OUTPUTS
The absolute path to the 7-Zip command-line utility.
#>
function Get-7zipCommandPath {
    [CmdletBinding()]
    [OutputType([string])]
    param()

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
