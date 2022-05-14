<#
    Entity representing a range that a technique can be executed in.
#>
class TechniqueRange {
    [ValidateRange(0, 3)]
    [int] $Id

    [ValidateSet('Near', 'Middle', 'Far', 'Very Far')]
    [string] $Name
}
