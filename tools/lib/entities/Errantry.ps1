<#
    Entity representing an errantry that monsters can go on to learn techniques.
#>
class Errantry {
    # The order in which the columns should appear in the finished CSV data.
    # This should align with the column order in the SQLite database tables, since the `sqlite3`
    # utility doesn't use the header when importing CSV tables, only the column order.
    static [string[]] $ColumnOrder = @(
        'ErrantryId', 'ErrantryName', 'TechniqueTypeId'
    )

    
    [ValidateRange(1, 5)]
    [int] $ErrantryId

    [ValidateSet('Papas', 'Mandy', 'Parepare', 'Torble Sea', 'Kawrea')]
    [string] $ErrantryName

    # The type of techniques (besides Basic, and in rare cases Special)
    # that can be learned at the errantry.
    [ValidateRange(2, 6)]
    [int] $TechniqueTypeId
}
