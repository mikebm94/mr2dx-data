<#
    Entity representing a unique ability that an attacking or defending monster
    can possess and activate during battle.
#>
class BattleSpecial {
    [ValidateRange(1, 13)]
    [int] $BattleSpecialId

    [ValidateLength(3, 12)]
    [ValidatePattern('^[A-Z][a-z]{2,}$')]
    [string] $BattleSpecialName

    # The priority of the battle special over other battle specials.
    # If the battle special attempts to trigger while another battle special is active,
    # it will not trigger if the other battle special has a higher priority (lower number.)
    [ValidateRange(0, 12)]
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
    # The names of properties that are not needed in the finished data.
    static [string[]] $IntermediateProperties = @( 'Flag' )

    # Flag name used in the games data files to specify a battle special.
    [ValidateSet(
        'SOKO', 'GYAKU', 'KONJO', 'SHUCHU', 'TOUKON', 'FUNNU',
        'GAMAN', 'YOYU', 'HISSHI', 'GENKI', 'HONKI', 'DEISUI', 'DANKETSU'
    )]
    [string] $Flag
}
