<#
    Entity class representing a technique scraped from LegendCup.com,
    including additional data points not needed in the finished data.
#>
class TechniqueScraped {
    [ValidateRange(0, 37)]
    [int] $BreedId

    [ValidateRange(1, 4)]
    [int] $TechniqueRangeId

    [ValidateRange(1, 6)]
    [int] $Slot

    [ValidatePattern('^\w+(?:-\w+)*(?: \w+(?:-\w+)*)*$')]
    [string] $Name

    [ValidateRange(0, 5)]
    [int] $TechniqueTypeId

    [ValidateRange(0, 100)]
    [int] $GutsCost

    [ValidateRange(0, 100)]
    [int] $Force

    [ValidateRange(-50, 50)]
    [int] $HitPercent

    [ValidateRange(0, 100)]
    [int] $Withering

    [ValidateRange(0, 100)]
    [int] $Sharpness

    [string] $Effect

    [ValidateRange(1.0, 15.0)]
    [float] $DurationHit

    [ValidateRange(1.0, 15.0)]
    [float] $DurationMiss

    # LegendCup data uses this to specify which errantry (or errantries),
    # if any, the technique can be learned at.
    [int] $Errantry
}
