<#
    Entity representing the nature of a technique.
#>
class TechniqueNature {
    [ValidateRange(0, 2)]
    [int] $Id

    [ValidateSet('Normal', 'Good', 'Bad')]
    [string] $TechniqueNatureName
}

<#
    Entity representing the nature of a technique,
    including data points not needed in the finished data.
#>
class TechniqueNatureIntermediate : TechniqueNature {
    # Flag name used in the games technique data files to specify a nature.
    [ValidateSet('NORMAL', 'YOI', 'WARU')]
    [string] $Flag
}
