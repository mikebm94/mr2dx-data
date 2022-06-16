<#
    Entity representing a type of force that techniques can draw
    their power from.
#>
class ForceType {
    [ValidateRange(1, 2)]
    [int] $ForceTypeId

    [ValidateSet('Power', 'Intelligence')]
    [string] $ForceTypeName
}

<#
    Entity representing a type of force that techniques can draw their power
    from, including data points not needed in the finished data.
#>
class ForceTypeIntermediate : ForceType {
    # The names of properties that are not needed in the finished data.
    static [string[]] $IntermediateProperties = @( 'Flag' )
    
    # Flag name used in the games technique data files to specify a force type.
    [ValidateSet('POW', 'IQ')]
    [string] $Flag
}
