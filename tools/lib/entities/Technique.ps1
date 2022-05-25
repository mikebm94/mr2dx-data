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

    # The amount of guts used to perform the technique.
    [ValidateRange(0, 100)]
    [int] $GutsCost
}

<#
    Entity representing a technique that can be performed
    by a certain monster breed during battle.
#>
class Technique : TechniqueBase {
    # The order in which the columns should appear in the finished CSV data.
    static [string[]] $ColumnOrder = @(
        'BreedId', 'TechniqueRangeId', 'Slot', 'Name', 'TechniqueTypeId', 'ForceTypeId',
        'TechniqueNatureId', 'HitPercent', 'Force', 'Withering', 'Sharpness', 'GutsCost',
        'GutsDrain', 'HpRecovery', 'HpDrain', 'SelfDamageHit', 'SelfDamageMiss',
        'Effect', 'DurationHit', 'DurationMiss'
    )

    # The ID of the range that the technique can be performed at.
    [ValidateRange(0, 3)]
    [int] $TechniqueRangeId

    # The name of the technique.
    [ValidatePattern('^\w+(?:-\w+)*(?: \w+(?:-\w+)*)*$')]
    [string] $Name

    # The ID of the technique's type.
    [ValidateRange(0, 5)]
    [int] $TechniqueTypeId

    # The ID of the technique's force type.
    [ValidateRange(0, 1)]
    [int] $ForceTypeId

    # The ID of the technique's nature.
    [ValidateRange(0, 2)]
    [int] $TechniqueNatureId

    # The amount of guts stolen from the opponent on success.
    [ValidateRange(0, 255)]
    [int] $GutsDrain
    
    # The amount of HP stolen from the opponent on success.
    [ValidateRange(0, 255)]
    [int] $HpDrain
    
    # The amount of HP recovered by the monster on success.
    [ValidateRange(0, 255)]
    [int] $HpRecovery

    # The amount of damage to the monster on success.
    [ValidateRange(0, 255)]
    [int] $SelfDamageHit
    
    # The amount of damage to the monster on failure.
    [ValidateRange(0, 255)]
    [int] $SelfDamageMiss

    # The description of the technique's special effect, if any.
    [string] $Effect

    # The time in seconds taken when the technique hits the opponent.
    [ValidateRange(1.0, 15.0)]
    [float] $DurationHit

    # The time in seconds taken when the technique misses the opponent.
    [ValidateRange(1.0, 15.0)]
    [float] $DurationMiss
}

<#
    Entity representing a technique extracted from the game files,
    including data points not needed in the finished data.
#>
class TechniqueExtracted : TechniqueBase {
    [ValidateRange(0, 3)]
    [int] $TechniqueRangeId

    <#
        Every technique in a monster breed's technique data file is given a
        number. These numbers are used in bitmasks in other data files to
        specify multiple techniques, for example, in the shrine data file
        to specify which techniques the monster will have when obtained.
    
        This number will not be used in the finished data. Instead, join
        tables will be created as needed.

        A monster breed can have a total of 24 available techniques,
        but most have less than this.
    #>
    [ValidateRange(0, 23)]
    [int] $Index

    # Flag name used in the game's technique data files to specify a type.
    [ValidateSet(
        'KIHON', 'MEICHU', 'DAI_DAMAGE', 'GUTS_DOWN', 'CRITICAL', 'HISSATSU'
    )]
    [string] $TechniqueTypeFlag

    # Flag name used in the game's technique data files to specify a force type.
    [ValidateSet('POW', 'IQ')]
    [string] $ForceTypeFlag

    # Flag name used in the game's technique data files to specify a nature.
    [ValidateSet('NORMAL', 'YOI', 'WARU')]
    [string] $TechniqueNatureFlag

    [ValidateRange(0, 255)]
    [int] $GutsDrain

    [ValidateRange(0, 255)]
    [int] $HpDrain
    
    [ValidateRange(0, 255)]
    [int] $HpRecovery

    [ValidateRange(0, 255)]
    [int] $SelfDamageHit
    
    [ValidateRange(0, 255)]
    [int] $SelfDamageMiss
}

<#
    Entity representing a technique scraped from LegendCup.com used to obtain
    data points that cannot be extracted from the game files.
#>
class TechniqueLegendCup : TechniqueBase {
    # LegendCup uses 1-4 for range IDs instead of 0-3.
    [ValidateRange(1, 4)]
    [int] $TechniqueRangeIdLegendCup

    [ValidatePattern('^\w+(?:-\w+)*(?: \w+(?:-\w+)*)*$')]
    [string] $Name

    # LegendCup technique types have different IDs.
    [ValidateRange(0, 5)]
    [int] $TechniqueTypeIdLegendCup

    [string] $Effect

    [ValidateRange(1.0, 15.0)]
    [float] $DurationHit

    [ValidateRange(1.0, 15.0)]
    [float] $DurationMiss

    # LegendCup data uses this to specify which errantry (or errantries),
    # if any, the technique can be learned at.
    [int] $Errantry
}
