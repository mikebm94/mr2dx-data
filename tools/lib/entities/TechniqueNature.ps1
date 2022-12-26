<#
    Entity representing the nature of a technique.
#>
class TechniqueNature {
    # The order in which the columns should appear in the finished CSV data.
    # This should align with the column order in the SQLite database tables, since the `sqlite3`
    # utility doesn't use the header when importing CSV tables, only the column order.
    static [string[]] $ColumnOrder = @( 'TechniqueNatureId', 'TechniqueNatureName' )

    
    [ValidateRange(1, 3)]
    [int] $TechniqueNatureId

    [ValidateSet('Normal', 'Good', 'Bad')]
    [string] $TechniqueNatureName
}

<#
    Entity representing the nature of a technique,
    including data points not needed in the finished data.
#>
class TechniqueNatureIntermediate : TechniqueNature {
    # Flag name used in the games technique data files to specify a nature.
    [ValidateSet('NORMAL', 'YOI', 'WARU')]
    [string] $Flag
}
