<#
    Entity representing a monster that can be obtained at the shrine.
#>
class ShrineMonster {
    [int] $ShrineMonsterId

    [int] $MonsterTypeId

    # The initial lifespan in weeks.
    [ValidateRange(1, 600)]
    [int] $Lifespan

    # The initial nature value. (-100 = Worst, 100 = Best)
    [ValidateRange(-100, 100)]
    [int] $Nature

    [ValidateRange(1, 4)]
    [int] $GrowthTypeId

    # The initial stat values.

    [ValidateRange(0, 999)]
    [int] $Lif

    [ValidateRange(0, 999)]
    [int] $Pow

    [ValidateRange(0, 999)]
    [int] $IQ

    [ValidateRange(0, 999)]
    [int] $Ski

    [ValidateRange(0, 999)]
    [int] $Spd

    [ValidateRange(0, 999)]
    [int] $Def

    # The levels/ranks (1-5, E-A) determining how many points are gained when the corresponding stat
    # is increased by a drill or battle. These are also used as a factor in the combination algorithm
    # to calculate adjusted stat values which determine the stat order of the parents and child.

    [ValidateRange(1, 5)]
    [int] $LifGainLvl

    [ValidateRange(1, 5)]
    [int] $PowGainLvl

    [ValidateRange(1, 5)]
    [int] $IQGainLvl

    [ValidateRange(1, 5)]
    [int] $SkiGainLvl

    [ValidateRange(1, 5)]
    [int] $SpdGainLvl

    [ValidateRange(1, 5)]
    [int] $DefGainLvl

    # The level/rank (1-5 / E-A) determining how fast the monster can move around the arena during battle.
    [ValidateRange(1, 5)]
    [int] $ArenaSpeedLvl

    # Id,Name,Main,Sub,Lifespan,Nature,Growth,LIF,POW,INT,SKI,SPD,DEF,Stat Gains,Move Speed,Guts Regen,Battle Specials,Initial Techniques,AutoMainAlgo,AutoSubAlgo,Good At,Total Stats,NotBaseline,NoOffsets

    # The number of frames it takes to recover one gut during battle. (Lower number = faster gut recovery)
    [ValidateRange(1, 30)]
    [int] $FramesPerGut

    # A boolean (0 = False, 1 = True) specifying whether the stats/parameters for this shrine monster
    # are different than the baseline stats/parameters for it's monster type.
    [ValidateRange(0, 1)]
    [int] $DiffersFromBaseline

    # A boolean (0 = False, 1 = True) specifying whether randomized offsets will be applied
    # to the initial stats when the monster is obtained at the shrine.
    [ValidateRange(0, 1)]
    [int] $OffsetsApplied
}

<#
    Entity representing a ShrineMonster extracted from the game's data files with data points
    that will be split to other data tables for data normalization purposes.
#>
class ShrineMonsterExtracted : ShrineMonster {
    # A combination of BattleSpecial IDs (zero-based) stored as a bitmask
    # specifying the shrine monster's battle specials.
    [int] $BattleSpecialsBitmask

    # A combination of Forte IDs (zero-based) stored as a bitmask specifying the shrine monster's fortes.
    [int] $FortesBitmask

    # A combination of Technique numbers (0-23) stored as a bitmask specifying the initial techniques.
    [int] $TechniquesBitmask
}
