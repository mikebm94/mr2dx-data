<#
    Entity class representing a monster breed, including additional
    data points not needed in the finished data.
#>
class BreedIntermediate {
    [ValidateRange(0, 37)]
    [int] $Id

    # Two-letter initials used in some game data files to specify a breed.
    [ValidatePattern('^[A-Z]{2}$')]
    [string] $Initials

    [ValidatePattern('^[A-Z][a-z]{2,}(?: [A-Z][a-z]{2,})?$')]
    [string] $Name
}
