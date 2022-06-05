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
#   in development and for generating other database formats
#   such as a SQLite database.
[SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '')]
$FinishedDataPath = Join-Path $DataPath 'csv/'

# data/sqlite/
#   Directory for the SQLite database generated from the finished data.
[SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '')]
$SQLiteDataPath = Join-Path $DataPath 'sqlite/'

# data/intermediate/
#   Directory for intermediate data compiled manually
#   that is used to help generate the finished data tables.
$IntermediateDataPath = Join-Path $DataPath 'intermediate/'

# data/intermediate/extracted/
#   Directory for intermediate data extracted from the MR2DX game files
#   that is used to help generate the finished data tables.
[SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '')]
$ExtractedIntermediateDataPath = Join-Path $IntermediateDataPath 'extracted/'

# data/intermediate/scraped/
#   Directory for intermediate data scraped from the web
#   that is used to help generate the finished data tables.
[SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '')]
$ScrapedIntermediateDataPath = Join-Path $IntermediateDataPath 'scraped/'

# game-files/
#   Directory for game files extracted from the MR2DX game data archive.
[SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '')]
$GameFilesPath = Join-Path $SourceTreeRoot 'game-files/'


# For directories that can be fully repopulated via scripts
# and must exist, create them if needed.
foreach ($path in
    $FinishedDataPath,
    $SQLiteDataPath,
    $ExtractedIntermediateDataPath,
    $ScrapedIntermediateDataPath
) {
    if (-not (Test-Path $path -PathType Container)) {
        New-Item -Path $path -ItemType Directory | Out-Null
    }
}
