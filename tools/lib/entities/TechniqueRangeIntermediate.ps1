<#
    Entity representing a range that a technique can be executed in,
    including data points not needed in the finished data.
#>
class TechniqueRangeIntermediate {
    [ValidateRange(0, 3)]
    [int] $Id

    # Technique data scraped from LegendCup.com uses one-based indexes
    # for technique ranges.
    [ValidateRange(1, 4)]
    [int] $IdLegendCup

    # Flag name used in the games technique data files to specify a range.
    [ValidateSet('NEAR', 'MIDDLE', 'FAR', 'VERYFAR')]
    [string] $Flag

    [ValidateSet('Near', 'Middle', 'Far', 'Very Far')]
    [string] $Name
}
