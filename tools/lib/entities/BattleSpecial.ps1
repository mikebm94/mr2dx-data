<#
    Entity representing a unique ability that an attacking or defending monster
    can possess and activate during battle.
#>
class BattleSpecial {
    # 12 is missing because that battle special ("Drunk") is not used in the game.
    [ValidateSet(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 13)]
    [int] $BattleSpecialId

    [ValidateLength(3, 12)]
    [ValidatePattern('^[A-Z][a-z]{2,}$')]
    [string] $BattleSpecialName

    # The priority of the battle special over other battle specials.
    # If the battle special attempts to trigger while another battle special is active,
    # it will not trigger if the other battle special has a higher priority (lower number.)
    #
    # Priority 6 is missing because that battle speciaL ("Drunk") is not used in the game.
    [ValidateSet(0, 1, 2, 3, 4, 5, 7, 8, 9, 10, 11, 12)]
    [int] $TriggerPriority

    # The analysis that Dadge will give when a monster possesses this battle special.
    [ValidateNotNullOrEmpty()]
    [string] $Analysis
}

<#
    Entity representing a unique ability that an attacking or defending monster can possess
    and activate during battle, including additional data points not needed in the finished data.
#>
class BattleSpecialIntermediate : BattleSpecial {
    # Flag name used in the games data files to specify a battle special.
    [ValidateSet(
        'SOKO', 'GYAKU', 'KONJO', 'SHUCHU', 'TOUKON', 'FUNNU',
        'GAMAN', 'YOYU', 'HISSHI', 'GENKI', 'HONKI', 'DANKETSU'
    )]
    [string] $Flag
}
