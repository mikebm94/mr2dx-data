<#
    Entity representing a pattern of growth a monster will experience during it's lifetime.
    Each of the 10 stages of a monsters life last a certain percentage of the monster's lifespan
    and yield different amounts of stat gains and overall performance of the monster.
#>
class GrowthType {
    [ValidateRange(1, 4)]
    [int] $GrowthTypeId

    [ValidateLength(3, 12)]
    [ValidatePattern('^[A-Z][a-z]{2,}(?: [A-Z][a-z]{2,})*$')]
    [string] $GrowthTypeName

    # The Stage properties below specify the percentage of the monsters lifespan
    # that will be spent in that stage of life.

    # Infancy (Worst stat-gains/performance.)
    [ValidateRange(0, 100)]
    [int] $Stage1

    [ValidateRange(0, 100)]
    [int] $Stage2

    [ValidateRange(0, 100)]
    [int] $Stage3

    [ValidateRange(0, 100)]
    [int] $Stage4

    # Prime (Best stat-gains/performance.)
    [ValidateRange(0, 100)]
    [int] $Stage5

    # Sub-Prime (Second-best stat-gains/performance, almost as good as prime.)
    [ValidateRange(0, 100)]
    [int] $Stage6

    [ValidateRange(0, 100)]
    [int] $Stage7

    [ValidateRange(0, 100)]
    [int] $Stage8

    [ValidateRange(0, 100)]
    [int] $Stage9

    # Twilight (Worst stat-gains/performance.)
    [ValidateRange(0, 100)]
    [int] $Stage10
}
