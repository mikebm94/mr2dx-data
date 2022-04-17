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
Imports CSV data from a file in the specified file manifest.

.OUTPUTS
The objects described by the content of the CSV file.
#>
function Import-Mr2dxDataFileCsv {
    [CmdletBinding()]
    [OutputType([object])]
    param(
        # The file manifest to search for the file
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

        # Specifies the delimiter that separates the property values
        # in the CSV file. The default is comma (`,`).
        # Only used for files in the 'GameFiles' manifest.
        [char]
        $Delimiter = ',',

        # A comma-separated list of strings to be used an alternate column
        # header row for the imported file. The column header determines
        # the property names of the objects created.
        [ValidateNotNull()]
        [string[]]
        $Header
    )

    $manifest = $FileManifests[$FileManifest]

    if ($null -eq $manifest) {
        throw "Failed to import CSV file: " +
              "File manifest named '${FileManifest}' does not exist."
    }

    $filePath = $manifest.Files[$FileKey]
    $fileEncoding = ''

    if ($null -eq $filePath) {
        throw "Failed to import CSV file: " +
              "No file path defined for key '{0}' in file manifest '{1}'." `
              -f $FileKey, $FileManifest
    }

    # File uses a non-default encoding.
    if ($filePath -is [PSCustomObject]) {
        $fileEncoding = $filePath.Codepage
        $filePath = $filePath.Path
    }

    $filePath = Join-Path $manifest.Directory $filePath

    if (-not (Test-Path $filePath -PathType Leaf)) {
        ErrorMsg "Failed to import CSV file:" `
                 "File '${filePath}' does not exist."
        
        if ($FileManifest -eq 'GameFiles') {
            ErrorMsg "Please run the game files extraction script first."
        }

        exit 1
    }

    $importArgs = @{
        'Path' = $filePath
    }

    if ($FileManifest -eq 'GameFiles') {
        $importArgs['Delimiter'] = $Delimiter
    }

    if ($fileEncoding) {
        $importArgs['Encoding'] = $fileEncoding
    }

    if ($Header) {
        $importArgs['Header'] = $Header
    }

    Import-Csv @importArgs
}


<#
.SYNOPSIS
Exports data to a CSV file in the specified file manifest.

.INPUTS
The PSObjects to export in CSV format.

.OUTPUTS
The file path the CSV data was exported to.
#>
function Export-Mr2dxDataFileCsv {
    [CmdletBinding()]
    param(
        # The file manifest to search for the file
        # corresponding to the specified file key.
        [Parameter(Mandatory, Position = 0)]
        [ValidateSet(
            'FinishedData',
            'ScrapedData'
        )]
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
            throw "Failed to export data to CSV file: " +
                  "File manifest named '${FileManifest}' does not exist."
        }

        $filePath = $manifest.Files[$FileKey]
        $fileEncoding = ''

        if ($null -eq $filePath) {
            throw "Failed to export data to CSV file: " +
                  "No file path defined for key '{0}' in file manifest '{1}'." `
                  -f $FileKey, $FileManifest
        }

        # File uses a non-default encoding.
        if ($filePath -is [PSCustomObject]) {
            $fileEncoding = $filePath.Codepage
            $filePath = $filePath.Path
        }

        $filePath = Join-Path $manifest.Directory $filePath

        $exportArgs = @{
            'Path'      = $filePath
            'UseQuotes' = 'AsNeeded'
        }

        if ($fileEncoding) {
            $exportArgs['Encoding'] = $fileEncoding
        }

        $input | Export-Csv @exportArgs | Out-Null
        
        return $filePath
    }
}


<#
.SYNOPSIS
Gets the content of an MR2DX game file.

.OUTPUTS
The full content of the file as a single string.
#>
function Get-GameFileContent {
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
    $filePath = $manifest.Files[$FileKey]
    $fileEncoding = ''

    if ($null -eq $filePath) {
        throw "Failed to get content of MR2DX game file:" +
              "No file path defined for key '${FileKey}'."
    }

    # File uses a non-default encoding.
    if ($filePath -is [PSCustomObject]) {
        $fileEncoding = [Encoding]::GetEncoding($filePath.Codepage)
        $filePath = $filePath.Path
    }

    $filePath = Join-Path $manifest.Directory $filePath

    if (-not (Test-Path $filePath -PathType Leaf)) {
        ErrorMsg "Failed to get content of MR2DX game file:" `
                 "File '${filePath}' does not exist."
        ErrorMsg "Please run the game files extraction script first."
        exit 1
    }

    if ($fileEncoding) {
        [File]::ReadAllText($filePath, $fileEncoding)
    }
    else {
        [File]::ReadAllText($filePath)
    }
}
