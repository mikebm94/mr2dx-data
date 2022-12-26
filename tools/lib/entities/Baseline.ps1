<#
    Entity representing the baseline stats and parameters for a monster type.
    If a specific monster type has no baseline, the baseline for the pure-breed
    of that monster type's main breed is used.

    These baselines are used for various things:
        Determines the stats and parameters of monsters obtained at the Market.
        Can determine the stats and parameters of certain monsters obtained at the Shrine.
        Used in the monster combination algorithm. 
#>
class Baseline {
    # The order in which the columns should appear in the finished CSV data.
    # This should align with the column order in the SQLite database tables, since the `sqlite3`
    # utility doesn't use the header when importing CSV tables, only the column order.
    static [string[]] $ColumnOrder = @(
        'MainBreedId', 'SubBreedId', 'Lifespan', 'Nature', 'GrowthTypeId',
        'Lif', 'Pow', 'IQ', 'Ski', 'Spd', 'Def',
        'LifGainLvl', 'PowGainLvl', 'IQGainLvl', 'SkiGainLvl', 'SpdGainLvl', 'DefGainLvl',
        'ArenaSpeedLvl', 'FramesPerGut'
    )

    
    [ValidateRange(1, 38)]
    [int] $MainBreedId

    [ValidateRange(1, 38)]
    [int] $SubBreedId

    # The initial lifespan in weeks.
    [ValidateRange(1, 600)]
    [int] $Lifespan

    # The initial nature. (-100 = Worst, 100 = Best)
    [ValidateRange(-100, 100)]
    [int] $Nature

    # The ID of the growth type. (Normal, Precocious, Late Bloom, Sustainable)
    [ValidateRange(1, 4)]
    [int] $GrowthTypeId

    # The initial stats. These base stats are also used in the combination algorithm to determine offsets.

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

    # The level/rank (1-5/E-A) of the gains for each stat. The higher the level/rank,
    # the more points that will be gained when these stats are increased by drills and battles.

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

    # The number of frames it takes to recover one gut during battle. (Lower number = faster gut recovery)
    [ValidateRange(1, 30)]
    [int] $FramesPerGut
}


<#
    Entity representing a Baseline with additional data points that will be split
    into additional data tables for data normalization purposes.
#>
class BaselineExtracted : Baseline {
    # A bitmask of BattleSpecial IDs (zero-based, 0-12) specifying the monster type's baseline battle specials.
    [UInt32] $BattleSpecialsBitmask

    # A bitmask of Forte IDs (zero-based, 0-14) specifying the monster type's baseline fortes.
    [UInt32] $FortesBitmask

    # A bitmask of Technique numbers (0-23) specifying the monster type's initial techniques.
    [UInt32] $TechniquesBitmask
}
