<#
    Entity representing a drill or errantry that a monster does particularly well at, and thus gains
    an extra point towards the main stat for every completion of that drill or errantry stage.
    (Seen as a white box with a '+1' next to the stat.)
#>
class Forte {
    # The order in which the columns should appear in the finished CSV data.
    # This should align with the column order in the SQLite database tables, since the `sqlite3`
    # utility doesn't use the header when importing CSV tables, only the column order.
    static [string[]] $ColumnOrder = @( 'ForteId', 'ForteName' )

    
    [ValidateRange(1, 15)]
    [int] $ForteId

    [ValidateLength(3, 12)]
    [ValidatePattern('^[A-Z][a-z]{2,}(?: [A-Z][a-z]{2,})*$')]
    [string] $ForteName
}

<#
    Entity representing a Forte that includes intermediate data points not needed in the finished data.
#>
class ForteIntermediate : Forte {
    # Flag name used in the game's data files to specify a Forte.
    [ValidateSet(
        'T_DOMINO', 'T_STUDY', 'T_RUN', 'T_SHOOT', 'T_STONE', 'T_WOOD',
        'T_WEIGHT', 'T_MED', 'T_FLOOR', 'T_SWIM',
        'S_SEA', 'S_SNOW', 'S_DESERT', 'S_JUNGLE', 'S_VOLCANO'
    )]
    [string] $Flag
}
