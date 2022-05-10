<#
    Entity class representing the nature of a technique, including additional
    data points not needed in the finished data.
#>
class TechniqueNatureIntermediate {
    [ValidateRange(0, 2)]
    [int] $Id

    # Flag name used in the games technique data files to specify a nature.
    [ValidateSet('NORMAL', 'YOI', 'WARU')]
    [string] $Flag

    [ValidateSet('Normal', 'Good', 'Bad')]
    [string] $Name
}
