<#
    Entity representing a type of technique.
#>
class TechniqueType {
    [ValidateRange(1, 6)]
    [int] $TechniqueTypeId

    [ValidateSet('Basic', 'Hit', 'Heavy', 'Withering', 'Sharp', 'Special')]
    [string] $TechniqueTypeName
}

<#
    Entity representing a type of technique,
    including data points not needed in the finished data.
#>
class TechniqueTypeIntermediate : TechniqueType {
    # The names of properties that are not needed in the finished data.
    static [string[]] $IntermediateProperties = @( 'TechniqueTypeIdLegendCup', 'Flag' )

    # Technique data scraped from LegendCup.com uses different indexes
    # for technique types.
    [ValidateRange(0, 5)]
    [int] $TechniqueTypeIdLegendCup

    # Flag name used in the games technique data files.
    [ValidateSet(
        'KIHON', 'MEICHU', 'DAI_DAMAGE', 'GUTS_DOWN', 'CRITICAL', 'HISSATSU'
    )]
    [string] $Flag
}
