<#
    Entity representing a range that a technique can be executed in.
#>
class TechniqueRange {
    # The order in which the columns should appear in the finished CSV data.
    # This should align with the column order in the SQLite database tables, since the `sqlite3`
    # utility doesn't use the header when importing CSV tables, only the column order.
    static [string[]] $ColumnOrder = @( 'TechniqueRangeId', 'TechniqueRangeName' )

    
    [ValidateRange(1, 4)]
    [int] $TechniqueRangeId

    [ValidateSet('Near', 'Middle', 'Far', 'Very Far')]
    [string] $TechniqueRangeName
}

<#
    Entity representing a range that a technique can be executed in,
    including data points not needed in the finished data.
#>
class TechniqueRangeIntermediate : TechniqueRange {
    # Flag name used in the games technique data files to specify a range.
    [ValidateSet('NEAR', 'MIDDLE', 'FAR', 'VERYFAR')]
    [string] $Flag
}
