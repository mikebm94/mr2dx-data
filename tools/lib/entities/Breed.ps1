<#
    Entity representing a monster breed.
#>
class Breed {
    [ValidateRange(1, 38)]
    [int] $BreedId

    [ValidateLength(3, 12)]
    [ValidatePattern('^[A-Z][a-z]{2,}(?: [A-Z][a-z]{2,})?$')]
    [string] $BreedName
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
