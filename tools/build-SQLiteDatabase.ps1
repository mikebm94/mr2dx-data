#!/usr/bin/env pwsh

[CmdletBinding()]
param()


$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'lib/file-utils.ps1')


$ScriptName = (Get-Item -Path $MyInvocation.MyCommand.Path).Name


function Main {
    [CmdletBinding()]
    param()

    Write-Host 'Generating MR2DX SQLite database ...'

    $databasePath = (Get-ManifestFileInfo SQLiteData SQLiteDatabase).FullPath

    # Path to the SQL script used to create the database schema.
    $schemaScriptPath = Join-Path $SQLiteDataPath 'mr2dx-data.sql'

    # Table columns that should receive NULL instead of an empty string when the imported CSV data
    # has no value for that column.
    $nullableTableColumns = @{
        'MonsterTypes' = @( 'SubBreedId' )
    }


    if (Test-Path -Path $databasePath -PathType Leaf) {
        Write-Host 'Deleting existing database ...'
        Remove-Item -Path $databasePath -Force
    }


    Write-Host 'Executing sqlite3 command line utility ...'

    Get-SqliteDbGenerationCommands $schemaScriptPath $nullableTableColumns |
        sqlite3 $databasePath 2>&1 |
        Tee-Object -Variable sqliteOutput
    
    $sqliteExitCode = $LASTEXITCODE
    $sqliteStderr = $sqliteOutput | Where-Object { $PSItem -is [Management.Automation.ErrorRecord] }

    Write-Host "sqlite3 exited with code: ${sqliteExitCode}"

    if (($LASTEXITCODE -ne 0) -or ($null -ne $sqliteStderr)) {
        Remove-Item -Path $databasePath -Force -ErrorAction Ignore
        Abort "${ScriptName}: fatal: Failed to create the SQLite database."
    }

    Write-Host "Saved SQLite database to '${databasePath}'."
}


<#
.SYNOPSIS
Gets the commands needed to generate a SQLite database from the finished CSV data.
#>
function Get-SqliteDbGenerationCommands {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        # The path to an SQL script used to create the database schema.
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $SchemaScriptPath,

        <#
          A hashtable mapping table names to an array of column names that should receive NULLs
          instead of empty strings.

          The .import command normally inserts an empty string when a column in the CSV data contains
          no value. Use this parameter to specify columns that should be set to NULL instead of
          an empty string.
        #>
        [Parameter(Position = 1)]
        [hashtable]
        [ValidateNotNull()]
        $NullableTableColumn = @{}
    )

    Write-Output '.bail on'
    Write-Output '.echo on'
    Write-Output ".read '${SchemaScriptPath}'"

    $finishedDataFilesInfo = Get-ManifestFileInfo FinishedData

    foreach ($fileInfo in $finishedDataFilesInfo) {
        $importArgs = @{
            'SourcePath' = $fileInfo.FullPath
            'TargetTable' = $fileInfo.Key
            'NullableColumn' = $NullableTableColumn[$fileInfo.Key]
        }

        Get-SqliteImportCsvCommands @importArgs
    }

    Write-Output '.quit'
}


<#
.SYNOPSIS
Gets the commands needed to import CSV data into a table.

.NOTES
This cmdlet expects the first line of the CSV file to contain the column names.
#>
function Get-SqliteImportCsvCommands {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        # The path to the CSV file to import into the target table.
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $SourcePath,

        # The name of the table to import the CSV data into.
        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]
        $TargetTable,

        <#
          The name of the column(s) that should receive NULLs instead of empty strings.

          The .import command normally inserts an empty string when a column in the CSV data contains
          no value. Use this parameter to specify columns that should be set to NULL instead of
          an empty string.
        #>
        [string[]]
        $NullableColumn
    )

    if (($null -eq $NullableColumn) -or ($NullableColumn.Count -lt 1)) {
        return ".import --csv --skip 1 '${SourcePath}' ${TargetTable}"
    }

    <#
    Create a temporary view and trigger. When importing the specified CSV file, the data will actually
    be inserted into the temporary view. The temporary INSTEAD OF trigger set on the view
    converts empty strings to NULLs for the specified column(s) when inserting the row
    into the specified table.
    #>

    $columnNames = (Get-Content -LiteralPath $SourcePath -First 1) -split ','
    $viewName = "${TargetTable}TempView"
    $triggerName = "${viewName}_ConvertEmptyToNull"

    Write-Output @"
CREATE TEMP VIEW ${viewName} (
    $( $columnNames -join (',' + [System.Environment]::NewLine + '    ') )
)
AS SELECT * FROM ${TargetTable};

CREATE TEMP TRIGGER ${triggerName}
    INSTEAD OF INSERT ON ${viewName}
BEGIN
    INSERT INTO ${TargetTable} (
        $( $columnNames -join (',' + [System.Environment]::NewLine + '        ') )
    )
    VALUES (
"@

    $colCount = $columnNames.Count

    for ($i = 0; $i -lt $colCount; $i++) {
        $col = $columnNames[$i]
        $valueText = '        '

        if ($NullableColumn.Contains($col)) {
            
            $valueText += "CASE WHEN NEW.${col} = '' THEN NULL ELSE NEW.${col} END"
        }
        else {
            $valueText += "NEW.${col}"
        }

        if ($i -lt ($colCount - 1)) {
            $valueText += ','
        }

        Write-Output $valueText
    }
    
    Write-Output @"
    );
END;

.import --csv --skip 1 '${SourcePath}' ${viewName}
"@
}


Main
