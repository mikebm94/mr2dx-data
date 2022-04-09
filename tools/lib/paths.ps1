<#
    paths.ps1
        Defines paths to directories used by the data generation scripts.
        This prevents the need to update multiple files when the directory
        structure is changed.
#>

using namespace System.Diagnostics.CodeAnalysis


# The root directory of the repository/source-tree.
$SourceTreeRoot = Resolve-Path (Join-Path $PSScriptRoot '../../')

# data/
#   Directory for gathered MR2DX data and images.
$DataPath = Join-Path $SourceTreeRoot 'data/'

# data/csv/
#   Directory for finished CSV data tables that are suitable for use
#   in development and to generate the database.
[SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '')]
$FinishedDataPath = Join-Path $DataPath 'csv/'

# data/images/
#   Directory for images and icons such as technique icons.
[SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '')]
$ImageDataPath = Join-Path $DataPath 'images/'

# data/intermediate/
#   Directory for data that is used to help generate the finished data tables.
$IntermediateDataPath = Join-Path $DataPath 'intermediate/'

# data/intermediate/extracted/
#   Directory for intermediate data extracted from the MR2DX game files.
[SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '')]
$ExtractedDataPath = Join-Path $IntermediateDataPath 'extracted/'

# data/intermediate/scraped/
#   Directory for intermediate data scraped from the web.
[SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '')]
$ScrapedDataPath = Join-Path $IntermediateDataPath 'scraped/'

# game-files/
#   Directory for game files extracted from the MR2DX game data archive.
[SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '')]
$GameFilesPath = Join-Path $SourceTreeRoot 'game-files/'
