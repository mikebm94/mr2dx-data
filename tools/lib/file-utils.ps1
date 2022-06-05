<#
    file-utils.ps1
        Cmdlets for reading/writing files used by the data generation scripts. This abstraction
        allows changes to the way files are read/written without the need to change multiple files.
#>

using namespace System.IO
using namespace System.Text

. (Join-Path $PSScriptRoot 'file-manifests.ps1')
. (Join-Path $PSScriptRoot 'misc-utils.ps1')


<#
.SYNOPSIS
Gets the information of a specific file or all files in the specified file manifest.

.OUTPUTS
Hashtables containing the information for all files in the specified file manifest,
or for a specific file if the `FileKey` parameter was specified. An additional property `FullPath`
is added to the objects which is the file's `Path` joined with the manifest's directory.
#>
function Get-ManifestFileInfo {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        # The name of the file manifest of which to get it's files information.
        [Parameter(ParameterSetName = 'AllFiles', Mandatory, Position = 0, ValueFromPipeline)]
        [Parameter(ParameterSetName = 'OneFile', Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $FileManifest,

        # A key corresponding to a file defined in the specified file manifest.
        # If not specified, then the information for all files in the manifest is retrieved.
        [Parameter(ParameterSetName = 'OneFile', Mandatory, Position = 1, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]
        $FileKey
    )

    process {
        $manifest = $FileManifests[$FileManifest]

        if ($null -eq $manifest) {
            throw "File manifest named '${FileManifest}' does not exist."
        }

        if ($FileKey) {
            $fileInfo = $manifest.Files[$FileKey]

            if ($null -eq $fileInfo) {
                throw "Failed to get file path: " +
                      "No file info defined for key '${FileKey}' in manifest '${FileManifest}'."
            }
            elseif (-not $fileInfo.Path) {
                throw "Failed to get file path: " +
                      "No file path defined for key '${FileKey}' in manifest '${FileManifest}'."
            }

            return ([PSCustomObject]@{
                Key = $FileKey
                Path = $fileInfo.Path
                FullPath = Join-Path $manifest.Directory $fileInfo.Path
                FileType = $fileInfo.FileType
                CodePage = $fileInfo.CodePage
                IsStaticData = $fileInfo.IsStaticData
            })
        }
        
        foreach ($pair in $manifest.Files.GetEnumerator()) {
            $currentFileKey = $pair.Key
            $currentFileInfo = $pair.Value

            if ($null -eq $currentFileInfo) {
                throw "Failed to get file path: " +
                      "No file info defined for key '${currentFileKey}' in manifest '${FileManifest}'."
            }
            elseif (-not $currentFileInfo.Path) {
                throw "Failed to get file path: " +
                      "No file path defined for key '${currentFileKey}' in manifest '${FileManifest}'."
            }

            [PSCustomObject]@{
                Key = $currentFileKey
                Path = $currentFileInfo.Path
                FullPath = Join-Path $manifest.Directory $currentFileInfo.Path
                FileType = $currentFileInfo.FileType
                CodePage = $currentFileInfo.CodePage
                IsStaticData = $currentFileInfo.IsStaticData
            }
        }
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
        # The name of the file manifest to search for the file corresponding to the specified file key.
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $FileManifest,

        # A key corresponding to a file defined in the specified file manifest.
        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]
        $FileKey,

        # A comma-separated list of strings to be used an alternate column header row
        # for the imported file. The column header determines the property names of the objects created.
        [ValidateNotNull()]
        [string[]]
        $Header
    )

    $fileInfo = Get-ManifestFileInfo $FileManifest $FileKey

    if ($fileInfo.FileType -notin 'CSV','TSV') {
        throw "Failed to import CSV/TSV file: " +
              "File for key '${FileKey}' in manifest '${FileManifest}' is not a CSV/TSV file."
    }
    elseif (-not (Test-Path $fileInfo.FullPath -PathType Leaf)) {
        $errorMsg = "$( (Get-Item $MyInvocation.PSCommandPath).Name ): " +
                    "fatal: Failed to import CSV file: " +
                    "File '$( $fileInfo.FullPath )' does not exist."
        
        if ($FileManifest -eq 'GameFiles') {
            $errorMsg += " Please run the game files extraction script first."
        }

        Abort $errorMsg
    }

    $importArgs = @{
        'Path' = $fileInfo.FullPath
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
        # The name of the file manifest to search for the file corresponding to the specified file key.
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
        $fileInfo = Get-ManifestFileInfo $FileManifest $FileKey

        if ($fileInfo.FileType -notin 'CSV','TSV') {
            throw "Failed to export data to CSV/TSV file: " +
                  "File for key '${FileKey}' in manifest '${FileManifest}' is not a CSV/TSV file."
        }
        elseif ($fileInfo.IsStaticData) {
            throw "Failed to export data to CSV/TSV file: " +
                  "File for key '${FileKey}' in manifest '${FileManifest}' " +
                  "is static data (manually created) and should not be overwritten."
        }

        $exportArgs = @{
            'Path' = $fileInfo.FullPath
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
        
        return $fileInfo.FullPath
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
        # A key referring to a game file path defined in the 'GameFiles' manifest.
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]
        $GameFileKey
    )

    process {
        $fileInfo = Get-ManifestFileInfo GameFiles $GameFileKey

        if (-not (Test-Path $fileInfo.FullPath -PathType Leaf)) {
            Abort "$( (Get-Item $MyInvocation.PSCommandPath).Name ):" `
                  "fatal: Failed to get content of MR2DX game file:" `
                  "File '$( $fileInfo.FullPath )' does not exist." `
                  "Please run the game files extraction script first."
        }

        if ($null -ne $fileInfo.CodePage) {
            [File]::ReadAllText($fileInfo.FullPath, [Encoding]::GetEncoding($fileInfo.CodePage))
        }
        else {
            [File]::ReadAllText($fileInfo.FullPath)
        }
    }
}
