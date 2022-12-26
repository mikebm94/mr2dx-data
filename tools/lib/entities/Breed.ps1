<#
    Entity representing a monster breed.
#>
class Breed {
    # The order in which the columns should appear in the finished CSV data.
    # This should align with the column order in the SQLite database tables, since the `sqlite3`
    # utility doesn't use the header when importing CSV tables, only the column order.
    static [string[]] $ColumnOrder = @(
        'BreedId', 'BreedName', 'BloodStrength'
    )

    
    [ValidateRange(1, 38)]
    [int] $BreedId

    [ValidateLength(3, 12)]
    [ValidatePattern('^[A-Z][a-z]{2,}(?: [A-Z][a-z]{2,})?$')]
    [string] $BreedName

    # The combination strength of the breed. This helps determine the chance particular outcomes
    # when combining monsters. The blood strength of the parent monsters' main breeds is given more weight
    # in the combination outcomes of the child monster.
    [ValidateRange(1, 10)]
    [int] $BloodStrength
}

<#
    Entity representing a monster breed, including
    data points not needed in the finished data.
#>
class BreedIntermediate : Breed {
    # Two-letter initials used in some game data files to specify a breed.
    [ValidatePattern('^[A-Z]{2}$')]
    [string] $Initials
}
