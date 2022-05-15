<#
    Base class containing properties common
    to all entities representing a technique.
#>
class TechniqueBase {
    # The ID of the monster breed that the technique is available to.
    [ValidateRange(0, 37)]
    [int] $BreedId

    # The slot in the range that the technique occupies.
    [ValidateRange(1, 6)]
    [int] $Slot

    # The amount of guts used to perform the technique.
    [ValidateRange(0, 100)]
    [int] $GutsCost

    # Determines the amount of damage the technique can inflict.
    [ValidateRange(0, 100)]
    [int] $Force

    # Determines how likely the technique is to succeed in hitting the
    # opponent. The initial percentage is determined by the monsters Skill,
    # amount of guts, and the opponents Speed (and possibly other factors).
    # This hit percentage is then applied to it.
    [ValidateRange(-50, 50)]
    [int] $HitPercent

    # Determines how much the opponents guts are reduced when hit.
    [ValidateRange(0, 100)]
    [int] $Withering

    # Determines the chance of a critical hit on success.
    [ValidateRange(0, 100)]
    [int] $Sharpness
}

<#
    Entity representing a technique scraped from LegendCup.com used to obtain
    data points that cannot be extracted from the game files, including data
    points not needed in the finished data.
#>
class TechniqueLegendCup : TechniqueBase {
    # The ID of the range that the technique can be performed at.
    [ValidateRange(1, 4)]
    [int] $TechniqueRangeId

    # LegendCup technique types have different IDs.
    [ValidateRange(0, 5)]
    [int] $TechniqueTypeId
    
    # The name of the technique.
    [ValidatePattern('^\w+(?:-\w+)*(?: \w+(?:-\w+)*)*$')]
    [string] $Name

    # The description of the techniques special effect, if any.
    [string] $Effect

    # The time in seconds taken when the technique hits the opponent.
    [ValidateRange(1.0, 15.0)]
    [float] $DurationHit

    # The time in seconds taken when the technique misses the opponent.
    [ValidateRange(1.0, 15.0)]
    [float] $DurationMiss

    # LegendCup data uses this to specify which errantry (or errantries),
    # if any, the technique can be learned at.
    [int] $Errantry
}
