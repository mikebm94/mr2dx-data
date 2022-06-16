<#
    Entity representing the nature of a technique.
#>
class TechniqueNature {
    [ValidateRange(1, 3)]
    [int] $TechniqueNatureId

    [ValidateSet('Normal', 'Good', 'Bad')]
    [string] $TechniqueNatureName
}

<#
    Entity representing the nature of a technique,
    including data points not needed in the finished data.
#>
class TechniqueNatureIntermediate : TechniqueNature {
    # The names of properties that are not needed in the finished data.
    static [string[]] $IntermediateProperties = @( 'Flag' )
    
    # Flag name used in the games technique data files to specify a nature.
    [ValidateSet('NORMAL', 'YOI', 'WARU')]
    [string] $Flag
}
