<#
    Entity representing a unique ability that an attacking or defending monster
    can possess and activate during battle.
#>
class BattleSpecial {
    # The order in which the columns should appear in the finished CSV data.
    # This should align with the column order in the SQLite database tables, since the `sqlite3`
    # utility doesn't use the header when importing CSV tables, only the column order.
    static [string[]] $ColumnOrder = @(
        'BattleSpecialId', 'BattleSpecialName', 'TriggerPriority', 'Analysis'
    )


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
    # Flag name used in the games data files to specify a battle special.
    [ValidateSet(
        'SOKO', 'GYAKU', 'KONJO', 'SHUCHU', 'TOUKON', 'FUNNU',
        'GAMAN', 'YOYU', 'HISSHI', 'GENKI', 'HONKI', 'DEISUI', 'DANKETSU'
    )]
    [string] $Flag
}
