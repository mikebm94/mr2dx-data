<#
    Entity representing a type of force that techniques can draw their power
    from, including data points not needed in the finished data.
#>
class ForceTypeIntermediate {
    [ValidateRange(0, 1)]
    [int] $Id

    # Flag name used in the games technique data files to specify a force type.
    [ValidateSet('POW', 'IQ')]
    [string] $Flag

    [ValidateSet('Power', 'Intelligence')]
    [string] $Name
}
