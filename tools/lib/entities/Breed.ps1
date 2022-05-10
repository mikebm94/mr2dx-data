<#
    Entity class representing a monster breed.
#>
class Breed {
    [ValidateRange(0, 37)]
    [int] $Id

    [ValidatePattern('^[A-Z][a-z]{2,}(?: [A-Z][a-z]{2,})?$')]
    [string] $Name
}
