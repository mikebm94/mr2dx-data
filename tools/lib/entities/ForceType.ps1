<#
    Entity class representing a type of force that techniques can draw
    their power from.
#>
class ForceType {
    [ValidateRange(0, 1)]
    [int] $Id

    [ValidateSet('Power', 'Intelligence')]
    [string] $Name
}
