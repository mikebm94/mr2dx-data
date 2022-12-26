<#
    Entity representing a type of force that techniques can draw
    their power from.
#>
class ForceType {
    # The order in which the columns should appear in the finished CSV data.
    # This should align with the column order in the SQLite database tables, since the `sqlite3`
    # utility doesn't use the header when importing CSV tables, only the column order.
    static [string[]] $ColumnOrder = @( 'ForceTypeId', 'ForceTypeName' )
    
    
    [ValidateRange(1, 2)]
    [int] $ForceTypeId

    [ValidateSet('Power', 'Intelligence')]
    [string] $ForceTypeName
}

<#
    Entity representing a type of force that techniques can draw their power
    from, including data points not needed in the finished data.
#>
class ForceTypeIntermediate : ForceType {
    # Flag name used in the games technique data files to specify a force type.
    [ValidateSet('POW', 'IQ')]
    [string] $Flag
}
