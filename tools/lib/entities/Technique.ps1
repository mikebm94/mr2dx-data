<#
    Base class containing properties common to all entities representing a technique.
#>
class TechniqueBase {
    # The ID of the monster breed that the technique is available to.
    [ValidateRange(1, 38)]
    [int] $BreedId

    # The ID of the range that the technique can be performed at.
    [ValidateRange(1, 4)]
    [int] $TechniqueRangeId

    # The slot in the range that the technique occupies.
    [ValidateRange(1, 6)]
    [int] $Slot

    # Determines the amount of damage the technique can inflict.
    [ValidateRange(0, 100)]
    [int] $Damage

    # Determines how likely the technique is to succeed in hitting the opponent. The initial percentage
    # is determined by the monsters Skill, amount of guts, and the opponents Speed (and possibly other
    # factors.) This hit percentage is then applied to it.
    [ValidateRange(-50, 50)]
    [int] $HitPercent

    # Determines how much the opponents guts are reduced when hit.
    [ValidateRange(0, 100)]
    [int] $Withering

    # Determines the chance of a critical hit on success.
    [ValidateRange(0, 100)]
    [int] $Sharpness

    # The amount of guts used to perform the technique.
    [ValidateRange(10, 99)]
    [int] $GutsCost
}

<#
    Entity representing a technique that can be performed
    by a certain monster breed during battle.
#>
class Technique : TechniqueBase {
    # The maximum number of techniques that a monster breed can have.
    static [int] $MaxBreedTechniques = 24

    # The maximum number of techniques that a monster breed can have for a single range.
    static [int] $TechniqueSlotsPerRange = 6

    # The order in which the columns should appear in the finished CSV data.
    static [string[]] $ColumnOrder = @(
        'TechniqueId', 'BreedId', 'TechniqueRangeId', 'Slot', 'TechniqueName', 'TechniqueTypeId',
        'ForceTypeId', 'TechniqueNatureId', 'HitPercent', 'Damage', 'Withering', 'Sharpness',
        'GutsCost', 'GutsDrain', 'HpRecovery', 'HpDrain', 'SelfDamageHit', 'SelfDamageMiss',
        'Effect', 'DurationHit', 'DurationMiss'
    )

    [int] $TechniqueId

    # The name of the technique.
    [ValidateLength(3, 12)]
    [ValidatePattern('^\w+(?:-\w+)*(?: \w+(?:-\w+)*)*$')]
    [string] $TechniqueName

    # The ID of the technique's type.
    [ValidateRange(1, 6)]
    [int] $TechniqueTypeId

    # The ID of the technique's force type.
    [ValidateRange(1, 2)]
    [int] $ForceTypeId

    # The ID of the technique's nature.
    [ValidateRange(1, 3)]
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
    [ValidateLength(0, 48)]
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
    [int] $TechniqueId

    <#
      A number used to uniquely identify each of a monster breed's available techniques.
      A monster breed can have a total of 24 available techniques, but most have less than this.

      Every technique in a monster breed's technique data file is given a number. These numbers
      are used in bitmasks in other data files to specify multiple techniques, for example,
      in the shrine data file to specify which techniques the monster will have when obtained.
      This number and the monster breed ID comprise the techniques' primary key, and foreign keys
      used in join tables linking monsters to the techniques that they possess.
    #>
    [ValidateRange(0, 23)]
    [int] $TechniqueNumber

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
    Entity representing a technique scraped from LegendCup.com used to obtain data points
    that cannot be extracted from the game files.
#>
class TechniqueLegendCup : TechniqueBase {
    [ValidateLength(3, 12)]
    [ValidatePattern('^\w+(?:-\w+)*(?: \w+(?:-\w+)*)*$')]
    [string] $TechniqueName

    # LegendCup technique types have different IDs.
    [ValidateRange(0, 5)]
    [int] $TechniqueTypeIdLegendCup

    [ValidateLength(0, 48)]
    [string] $Effect

    [ValidateRange(1.0, 15.0)]
    [float] $DurationHit

    [ValidateRange(1.0, 15.0)]
    [float] $DurationMiss

    # LegendCup data uses this to specify which errantry (or errantries),
    # if any, the technique can be learned at.
    [int] $Errantry
}
