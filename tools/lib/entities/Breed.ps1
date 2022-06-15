<#
    Entity representing a monster breed.
#>
class Breed {
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
