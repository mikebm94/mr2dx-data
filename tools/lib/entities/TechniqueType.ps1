<#
    Entity representing a type of technique.
#>
class TechniqueType {
    [ValidateRange(0, 5)]
    [int] $Id

    [ValidateSet('Basic', 'Hit', 'Heavy', 'Withering', 'Sharp', 'Special')]
    [string] $Name
}
