<#
    Entity class representing a type of technique,
    including additional data points not needed in the finished data.
#>
class TechniqueTypeIntermediate {
    [ValidateRange(0, 5)]
    [int] $Id

    # Technique data scraped from LegendCup.com uses different indexes
    # for technique types.
    [ValidateRange(0, 5)]
    [int] $IdLegendCup

    # Flag name used in the games technique data files.
    [ValidateSet(
        'KIHON', 'MEICHU', 'DAI_DAMAGE', 'GUTS_DOWN', 'CRITICAL', 'HISSATSU'
    )]
    [string] $Flag

    [ValidateSet('Basic', 'Hit', 'Heavy', 'Withering', 'Sharp', 'Special')]
    [string] $Name
}