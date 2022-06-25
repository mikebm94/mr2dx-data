#!/usr/bin/env pwsh

<#
.SYNOPSIS
Builds a SQLite database populated using the finished CSV data files.

.DESCRIPTION
Invokes the SQLite command-line interface to create the database schema using the SQL script
data/sqlite/mr2dx-data.sql, then imports the CSV data files into their corresponding tables.

.NOTES
The SQLite CLI version must be 3.32.0 or higher to properly build the database.
#>

[CmdletBinding()]
param(
    # The command name or path to the SQLite3 command-line interface.
    # Defaults to the value of the SQLITE3 environment variable if it is set.
    # Otherwise, 'sqlite3' will be executed to build the database.
    #
    # Note: Version 3.32.0 or higher is required.
    [Parameter(Position = 0)]
    [string]
    $Sqlite3Command = [Environment]::GetEnvironmentVariable('SQLITE3')
)


$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'lib/file-utils.ps1')

$ScriptName = (Get-Item -Path $MyInvocation.MyCommand.Path).Name


function Main {
    [CmdletBinding()]
    param()

    Write-Host 'Generating MR2DX SQLite database ...'

    $databasePath = (Get-ManifestFileInfo SQLiteData SQLiteDatabase).FullPath
    $databaseBackupPath = "${databasePath}.bak"

    # Path to the SQL script used to create the database schema.
    $schemaScriptPath = Join-Path $SQLiteDataPath 'mr2dx-data.sql'

    # Table columns that should receive NULL instead of an empty string when the imported CSV data
    # has no value for that column.
    $nullableTableColumns = @{
        'MonsterTypes' = @( 'SubBreedId' )
    }


    if (Test-Path -Path $databasePath -PathType Leaf) {
        Write-Host 'Backing up existing database ...'
        Copy-Item -LiteralPath $databasePath -Destination $databaseBackupPath -Force -ErrorAction Continue
        if (-not $?) {
            $databaseBackupPath = $null
        }

        Write-Host 'Deleting existing database ...'
        Remove-Item -Path $databasePath -Force
    }


    Write-Host 'Executing sqlite3 command line utility ...'
    Write-Host "Using database schema creation script: ${schemaScriptPath}"

    if (-not $Sqlite3Command) {
        $Sqlite3Command = 'sqlite3'
    } else {
        Write-Host "Using sqlite3 command: ${Sqlite3Command}"
    }

    Get-SqliteDbGenerationCommands $schemaScriptPath $nullableTableColumns |
        & $Sqlite3Command $databasePath 2>&1 |
        Tee-Object -Variable sqliteOutput
    
    $sqliteExitCode = $LASTEXITCODE
    $sqliteStderr = $sqliteOutput | Where-Object { $PSItem -is [Management.Automation.ErrorRecord] }

    Write-Host "sqlite3 exited with code: ${sqliteExitCode}"

    if (($sqliteExitCode -ne 0) -or ($null -ne $sqliteStderr)) {
        Remove-Item -Path $databasePath -Force -ErrorAction Ignore
        Abort "${ScriptName}: fatal: Failed to create the SQLite database."
    }

    Write-Host "Saved SQLite database to '${databasePath}'."


    if (-not $databaseBackupPath) {
        Write-Host 'No database backup created. Skipping diff.'
    }
    else {
        Invoke-SqlDiff $databaseBackupPath $databasePath
    }
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
        [ValidateNotNull()]
        [hashtable]
        $NullableTableColumn = @{}
    )

    Write-Output '.bail on'
    Write-Output ".read '${SchemaScriptPath}'"
    Write-Output '.echo on'

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


<#
.SYNOPSIS
Invokes the 'sqldiff' utility (if installed) to get the difference between the newly built database
and the previously built database. The difference is output as an SQL script that can be used
to transform the old database into the new database and is saved as an SQL file.
#>
function Invoke-SqlDiff {
    [CmdletBinding()]
    param(
        # The path to the previously built and backed up database.
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $OldDatabasePath,

        # The path to the newly built database to compare to the old database.
        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]
        $NewDatabasePath
    )

    $sqldiffAppInfo = Get-ApplicationInfo -Name 'sqldiff' -First

    if ($null -eq $sqldiffAppInfo) {
        Write-Host "The 'sqldiff' utility is not installed. Skipping diff."
        return
    }

    Write-Host "Performing diff between old and new database ..."

    try {
        $sqldiff = $sqldiffAppInfo.Path
        $diffFilePath = "${databasePath}.sqldiff"

        & $sqldiff --primarykey $OldDatabasePath $NewDatabasePath
            | Out-File -LiteralPath $diffFilePath -Force
        
        Write-Host "sqldiff exited with code: ${LASTEXITCODE}"
        Write-Host "Saved diff/migration SQL script to '${diffFilePath}'."
    }
    catch {
        WarningMsg (
            "{0}: warning: Could not obtain database diff: {1}" `
                -f $ScriptName, $PSItem.Exception.Message
        )
    }
}


Main
