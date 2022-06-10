<#
    Entity representing a technique that can be learned at an errantry
    and the requirements that must be met to learn it.
#>
class ErrantryTechnique {
    # The ID of the errantry location the technique can be learned at.
    [ValidateRange(1, 5)]
    [int] $ErrantryId
    
    # The ID of the technique to be learned.
    [int] $TechniqueId

    # The probability that the technique will be learned even if the requirments aren't met.
    [ValidateRange(0, 100)]
    [int] $AutoLearnPercent

    <#
      The 6 stat requirements below define the minimum value of that stat needed to learn the technique.
      There can be between 0 and 2 stats that have a requirement.
      
      A value greater than 1 means that stat must have at least that amount to have a chance at learning
      the technique (not including the chance granted by AutoLearnPercent).

      A value of 1 means that the stat contributes toward the Stat Total needed to learn the technique,
      but has no minimum requirement in and of itself.

      A value of 0 means the stat has no effect on the chance of learning the technique.

      A monsters loyalty value counts point-for-point towards the Stat Total.
    #>

    # The minimum value of Life needed to learn the technique.
    [ValidateRange(0, 999)]
    [int] $Lif

    # The minimum value of Power needed to learn the technique.
    [ValidateRange(0, 999)]
    [int] $Pow

    # The minimum value of Intelligence needed to learn the technique.
    [ValidateRange(0, 999)]
    [int] $IQ

    # The minimum value of Skill needed to learn the technique.
    [ValidateRange(0, 999)]
    [int] $Ski

    # The minimum value of Speed needed to learn the technique.
    [ValidateRange(0, 999)]
    [int] $Spd

    # The minimum value of Defense needed to learn the technique.
    [ValidateRange(0, 999)]
    [int] $Def

    # The combined value of the required stats
    # needed to have above a 0% chance of learning the technique.
    [ValidateRange(0, 5994)]
    [int] $StatTotalMin

    # The combined value of the required stats
    # needed to have a 100% chance of learning the technique.
    [ValidateRange(0, 5994)]
    [int] $StatTotalMax

    # The nature a must have to learn the technique.
    # If this value is less than 0, the monster must have this nature or lower.
    # If this value is greater than 0, the monster must have this nature or higher.
    # If this value is equal to 0, the nature has no effect on the chance of learning the technique.
    [ValidateRange(-100, 100)]
    [int] $Nature

    # A tie-breaking priority value.
    # If multiple techniques at the same errantry location have a 100% chance of being learned,
    # the technique with the highest priority (lowest number) will be learned.
    [ValidateRange(1, 24)]
    [int] $Priority
}


<#
    Entity representing a technique that can be learned at an errantry and the requirements
    that must be met to learn it (scraped from LegendCup.com), including data points
    that will be normalized and used to build various other tables.
#>
class ErrantryTechniqueLegendCup : ErrantryTechnique {
    # The name of the technique (if any) required to be learned and used a number of times
    # before this technique can be learned.
    [ValidateLength(0, 12)]
    [ValidatePattern('^(?:\w+(?:-\w+)*(?: \w+(?:-\w+)*)*)?$')]
    [string] $ChainedTechniqueName

    # The number of times the required technique must be used before this technique can be learned.
    [ValidateRange(0, 50)]
    [int] $ChainedTechniqueUses

    # A list of sub-breed names (or monster type names, in the case of special monsters)
    # that a monster must be to learn this technique.
    [ValidatePattern('^(?:[A-Z][a-z]+(?: [A-Z][a-z]+)?(?:, [A-Z][a-z]+(?: [A-Z][a-z]+)?)*)?$')]
    [string] $RequiredSubBreedNames

    # A list of sub-breed names (or monster type names, in the case of special monsters)
    # that a monster must not be to learn this technique.
    [ValidatePattern('^(?:[A-Z][a-z]+(?: [A-Z][a-z]+)?(?:, [A-Z][a-z]+(?: [A-Z][a-z]+)?)*)?$')]
    [string] $LockedSubBreedNames
}
