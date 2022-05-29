<#
    file-utils.ps1
        Cmdlets for reading/writing files used by the data generation scripts.
        This abstraction allows changes to the way files are read/written
        without the need to change multiple files.
#>

using namespace System.IO
using namespace System.Text

. (Join-Path $PSScriptRoot 'file-manifests.ps1')
. (Join-Path $PSScriptRoot 'misc-utils.ps1')


<#
.SYNOPSIS
Gets the file keys and paths of all files in the specified file manifest.

.OUTPUTS
PSCustomObjects with `Key` and `Path` properties corresponding the file key and full path
of the files in the specified file manifest.
#>
function Get-ManifestFile {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        # The name of the file manifest of which to get it's files.
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]
        $FileManifest
    )

    process {
        $manifest = $FileManifests[$FileManifest]

        if ($null -eq $manifest) {
            throw "File manifest named '${FileManifest}' does not exist."
        }

        foreach ($pair in $manifest.Files.GetEnumerator()) {
            $fileKey = $pair.Key
            $fileInfo = $pair.Value

            if ($null -eq $fileInfo) {
                throw "Failed to get file path: " +
                      "No file info defined for key '${fileKey}' in manifest '${FileManifest}'."
            }
            elseif (-not $fileInfo.Path) {
                throw "Failed to get file path: " +
                      "No file path defined for key '${fileKey}' in manifest '${FileManifest}'."
            }

            [PSCustomObject]@{
                Key = $fileKey
                Path = Join-Path $manifest.Directory $fileInfo.Path
            }
        }
    }
}


<#
.SYNOPSIS
Gets the path to a file in the specified file manifest.

.OUTPUTS
The full path to the file with the specified key
in the specified file manifest.
#>
function Get-Mr2dxDataFilePath {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        # The name of the file manifest to search for the file
        # corresponding to the specified file key.
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $FileManifest,

        # A key corresponding to a file defined in the specified file manifest.
        [Parameter(Mandatory, Position = 1, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]
        $FileKey
    )

    process {
        $manifest = $FileManifests[$FileManifest]

        if ($null -eq $manifest) {
            throw "Failed to get file path: " +
                  "File manifest named '${FileManifest}' does not exist."
        }

        $fileInfo = $manifest.Files[$FileKey]

        if ($null -eq $fileInfo) {
            throw "Failed to get file path: " +
                  "No file info defined for key '${FileKey}' in manifest '${FileManifest}'."
        }
        elseif (-not $fileInfo.Path) {
            throw "Failed to get file path: " +
                  "No file path defined for key '${FileKey}' in manifest '${FileManifest}'."
        }

        Write-Output (Join-Path $manifest.Directory $fileInfo.Path)
    }
}


<#
.SYNOPSIS
Imports CSV/TSV data from a file in the specified file manifest.

.OUTPUTS
The objects described by the content of the CSV/TSV file.
#>
function Import-Mr2dxDataFileCsv {
    [CmdletBinding()]
    [OutputType([object])]
    param(
        # The name of the file manifest to search for the file
        # corresponding to the specified file key.
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $FileManifest,

        # A key corresponding to a file defined in the specified file manifest.
        [Parameter(Mandatory, Position = 1, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]
        $FileKey,

        # A comma-separated list of strings to be used an alternate column
        # header row for the imported file. The column header determines
        # the property names of the objects created.
        [ValidateNotNull()]
        [string[]]
        $Header
    )

    $manifest = $FileManifests[$FileManifest]

    if ($null -eq $manifest) {
        throw "Failed to import CSV/TSV file: " +
              "File manifest named '${FileManifest}' does not exist."
    }

    $fileInfo = $manifest.Files[$FileKey]

    if ($null -eq $fileInfo) {
        throw "Failed to import CSV/TSV file: " +
              "No file info defined for key '${FileKey}' in manifest '${FileManifest}'."
    }
    elseif (($fileInfo.FileType -ne 'CSV') -and ($fileInfo.FileType -ne 'TSV')) {
        throw "Failed to import CSV/TSV file: " +
              "File for key '${FileKey}' in manifest '${FileManifest}' is not a CSV/TSV file."
    }
    elseif (-not $fileInfo.Path) {
        throw "Failed to import CSV/TSV file: " +
              "No file path defined for key '${FileKey}' in manifest '${FileManifest}'."
    }

    $fullFilePath = Join-Path $manifest.Directory $fileInfo.Path

    if (-not (Test-Path $fullFilePath -PathType Leaf)) {
        $errorMsg = "$( (Get-Item $MyInvocation.PSCommandPath).Name ): " +
                    "fatal: Failed to import CSV file: " +
                    "File '${fullFilePath}' does not exist."
        
        if ($FileManifest -eq 'GameFiles') {
            $errorMsg += " Please run the game files extraction script first."
        }

        Abort $errorMsg
    }

    $importArgs = @{
        'Path' = $fullFilePath
        'Delimiter' = switch ($fileInfo.FileType) {
            'CSV' { ',' }
            'TSV' { "`t" }
        }
    }

    if ($null -ne $fileInfo.CodePage) {
        $importArgs['Encoding'] = $fileInfo.CodePage
    }

    if ($Header) {
        $importArgs['Header'] = $Header
    }

    Import-Csv @importArgs
}


<#
.SYNOPSIS
Exports data to a CSV/TSV file in the specified file manifest.

.INPUTS
The PSObjects to export in CSV/TSV format.

.OUTPUTS
The file path the CSV/TSV data was exported to.
#>
function Export-Mr2dxDataFileCsv {
    [CmdletBinding()]
    param(
        # The name of the file manifest to search for the file
        # corresponding to the specified file key.
        [Parameter(Mandatory, Position = 0)]
        [ValidateSet('FinishedData', 'ExtractedData', 'ScrapedData')]
        [string]
        $FileManifest,

        # A key corresponding to a file defined in the specified file manifest.
        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]
        $FileKey,

        # Specifies the objects to export in CSV format.
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNull()]
        [PSObject]
        $InputObject
    )

    end {
        $manifest = $FileManifests[$FileManifest]

        if ($null -eq $manifest) {
            throw "Failed to export data to CSV/TSV file: " +
                  "File manifest named '${FileManifest}' does not exist."
        }

        $fileInfo = $manifest.Files[$FileKey]

        if ($null -eq $fileInfo) {
            throw "Failed to export data to CSV/TSV file: " +
                  "No file info defined for key '${FileKey}' in manifest '${FileManifest}'."
        }
        elseif (($fileInfo.FileType -ne 'CSV') -and ($fileInfo.FileType -ne 'TSV')) {
            throw "Failed to export data to CSV/TSV file: " +
                  "File for key '${FileKey}' in manifest '${FileManifest}' is not a CSV/TSV file."
        }
        elseif (-not $fileInfo.Path) {
            throw "Failed to export data to CSV/TSV file: " +
                  "No file path defined for key '${FileKey}' in manifest '${FileManifest}'."
        }

        $fullFilePath = Join-Path $manifest.Directory $fileInfo.Path

        $exportArgs = @{
            'Path' = $fullFilePath
            'UseQuotes' = 'AsNeeded'
            'Delimiter' = switch ($fileInfo.FileType) {
                'CSV' { ',' }
                'TSV' { "`t" }
            }
        }

        if ($null -ne $fileInfo.CodePage) {
            $exportArgs['Encoding'] = $fileInfo.CodePage
        }

        $input | Export-Csv @exportArgs | Out-Null
        
        return $fullFilePath
    }
}


<#
.SYNOPSIS
Gets the content of an MR2DX game file.

.OUTPUTS
The full content of the file as a single string.
#>
function Get-Mr2dxGameFileContent {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        # A key referring to a game file path defined
        # in the 'GameFiles' manifest.
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]
        $FileKey
    )

    $manifest = $FileManifests['GameFiles']
    $fileInfo = $manifest.Files[$FileKey]

    if ($null -eq $fileInfo) {
        throw "Failed to get content of MR2DX game file: " +
              "No file info defined for key '${FileKey}'."
    }
    elseif (-not $fileInfo.Path) {
        throw "Failed to get content of MR2DX game file: " +
              "No file path defined for key '${FileKey}'."
    }

    $fullFilePath = Join-Path $manifest.Directory $fileInfo.Path

    if (-not (Test-Path $fullFilePath -PathType Leaf)) {
        Abort "$( (Get-Item $MyInvocation.PSCommandPath).Name ):" `
              "fatal: Failed to get content of MR2DX game file:" `
              "File '${fullFilePath}' does not exist." `
              "Please run the game files extraction script first."
    }

    if ($null -ne $fileInfo.CodePage) {
        [File]::ReadAllText($fullFilePath, [Encoding]::GetEncoding($fileInfo.CodePage))
    }
    else {
        [File]::ReadAllText($fullFilePath)
    }
}
