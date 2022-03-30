
# Directory for game files extracted from the MR2DX game data archive.
$GameFilesPath = Join-Path $PSScriptRoot '../game-files/'

# Directory for gathered MR2DX data and images.
$DataPath = Join-Path $PSScriptRoot '../data/'

# Directory for data that is used to help generate the finished data tables.
$IntermediateDataPath = Join-Path $DataPath 'intermediate/'

# Directory for intermediate data scraped from the web.
$ScrapedDataPath = Join-Path $IntermediateDataPath 'scraped/'

# Directory for intermediate data extracted from the MR2DX game files.
$ExtractedDataPath = Join-Path $IntermediateDataPath 'extracted/'

# Directory for finished CSV data tables that are suitable for use
# in development and to generate the database.
$FinishedDataPath = Join-Path $DataPath 'csv/'

# Directory for images and icons such as technique icons.
$ImageDataPath = Join-Path $DataPath 'images/'


<#
.SYNOPSIS
Create a hashtable from a collection of objects
using the specified properties as the keys and values.
#>
function ConvertTo-Hashtable {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        # The objects used to create the hashtable.
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNull()]
        [PSObject]
        $InputObject,

        # The property of the input objects to use as keys for the hashtable.
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNull()]
        [object]
        $KeyProperty,

        # The property of the input objects to use as values for the hashtable.
        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNull()]
        [object]
        $ValueProperty
    )

    begin {
        $table = @{}
    }

    process {
        $table.Add($InputObject.$KeyProperty, $InputObject.$ValueProperty)
    }

    end {
        return $table
    }
}
