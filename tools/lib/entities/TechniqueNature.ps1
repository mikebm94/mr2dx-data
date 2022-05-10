<#
    Entity class representing the nature of a technique.
#>
class TechniqueNature {
    [ValidateRange(0, 2)]
    [int] $Id

    [ValidateSet('Normal', 'Good', 'Bad')]
    [string] $Name
}
