<#
    Entity representing a range that a technique can be executed in.
#>
class TechniqueRange {
    [ValidateRange(1, 4)]
    [int] $TechniqueRangeId

    [ValidateSet('Near', 'Middle', 'Far', 'Very Far')]
    [string] $TechniqueRangeName
}

<#
    Entity representing a range that a technique can be executed in,
    including data points not needed in the finished data.
#>
class TechniqueRangeIntermediate : TechniqueRange {
    # Flag name used in the games technique data files to specify a range.
    [ValidateSet('NEAR', 'MIDDLE', 'FAR', 'VERYFAR')]
    [string] $Flag
}
