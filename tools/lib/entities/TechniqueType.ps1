<#
    Entity representing a type of technique.
#>
class TechniqueType {
    # The order in which the columns should appear in the finished CSV data.
    # This should align with the column order in the SQLite database tables, since the `sqlite3`
    # utility doesn't use the header when importing CSV tables, only the column order.
    static [string[]] $ColumnOrder = @( 'TechniqueTypeId', 'TechniqueTypeName' )

    
    [ValidateRange(1, 6)]
    [int] $TechniqueTypeId

    [ValidateSet('Basic', 'Hit', 'Heavy', 'Withering', 'Sharp', 'Special')]
    [string] $TechniqueTypeName
}

<#
    Entity representing a type of technique,
    including data points not needed in the finished data.
#>
class TechniqueTypeIntermediate : TechniqueType {
    # Technique data scraped from LegendCup.com uses different indexes
    # for technique types.
    [ValidateRange(0, 5)]
    [int] $TechniqueTypeIdLegendCup

    # Flag name used in the games technique data files.
    [ValidateSet(
        'KIHON', 'MEICHU', 'DAI_DAMAGE', 'GUTS_DOWN', 'CRITICAL', 'HISSATSU'
    )]
    [string] $Flag
}
