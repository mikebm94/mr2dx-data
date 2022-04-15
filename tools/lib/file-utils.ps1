<#
    file-utils.ps1
        Cmdlets for reading/writing files used by the data generation scripts.
        This abstraction allows changes to the way files are read/written
        without the need to change multiple files.
#>

. (Join-Path $PSScriptRoot 'file-manifests.ps1')
. (Join-Path $PSScriptRoot 'misc-utils.ps1')


<#
.SYNOPSIS
Imports CSV data from an MR2DX game file.

.OUTPUTS
The objects described by the content of the CSV file.
#>
function Import-GameFileCsv {
    [CmdletBinding()]
    [OutputType([object])]
    param(
        # A key referring to a game file path defined
        # in the `GameFiles` hashtable.
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]
        $FileKey,

        # Specifies the delimiter that separates the property values
        # in the CSV file. The default is comma (`,`).
        [Parameter(Position = 1)]
        [char]
        $Delimiter = ',',

        # A comma-separated list of strings to be used an alternate column
        # header row for the imported file. The column header determines
        # the property names of the objects created.
        [ValidateNotNull()]
        [string[]]
        $Header
    )

    $filePath = $GameFiles[$FileKey]
    $fileEncoding = 'UTF8NoBOM'

    if ($null -eq $filePath) {
        throw "Failed to import CSV data from MR2DX game file: " +
              "No file path defined for key '${FileKey}'."
    }

    # File uses a non-default encoding.
    if ($filePath -is [PSCustomObject]) {
        $fileEncoding = $filePath['Codepage']
        $filePath = $filePath['Path']
    }

    $filePath = Join-Path $GameFilesPath $filePath

    if (-not (Test-Path $filePath -PathType Leaf)) {
        Abort "Failed to import CSV data from MR2DX game file:" `
              "File '${filePath}' does not exist." `
              "Please run the game archive extraction script first."
    }

    $importArgs = @{
        'Path'      = $filePath
        'Delimiter' = $Delimiter
        'Encoding'  = $fileEncoding
    }

    if ($Header) {
        $importArgs['Header'] = $Header
    }

    Import-Csv @importArgs
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
        # in the `GameFiles` hashtable.
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]
        $FileKey
    )

    $filePath = $GameFiles[$FileKey]
    $fileEncoding = 'UTF8NoBOM'

    if ($null -eq $filePath) {
        throw "Failed to get content of MR2DX game file:" +
              "No file path defined for key '${FileKey}'."
    }

    # File uses a non-default encoding.
    if ($filePath -is [PSCustomObject]) {
        $fileEncoding = $filePath['Codepage']
        $filePath = $filePath['Path']
    }

    $filePath = Join-Path $GameFilesPath $filePath

    if (-not (Test-Path $filePath -PathType Leaf)) {
        Abort "Failed to get content of MR2DX game file:" `
              "File '${filePath}' does not exist." `
              "Please run the game archive extraction script first."
    }

    Get-Content $filePath -Raw -Encoding $fileEncoding
}
