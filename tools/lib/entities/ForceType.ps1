<#
    Entity representing a type of force that techniques can draw
    their power from.
#>
class ForceType {
    [ValidateRange(0, 1)]
    [int] $Id

    [ValidateSet('Power', 'Intelligence')]
    [string] $Name
}

<#
    Entity representing a type of force that techniques can draw their power
    from, including data points not needed in the finished data.
#>
class ForceTypeIntermediate : ForceType {
    # Flag name used in the games technique data files to specify a force type.
    [ValidateSet('POW', 'IQ')]
    [string] $Flag
}
