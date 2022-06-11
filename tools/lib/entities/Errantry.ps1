<#
    Entity representing an errantry that monsters can go on to learn techniques.
#>
class Errantry {
    [ValidateRange(1, 5)]
    [int] $ErrantryId

    [ValidateSet('Papas', 'Mandy', 'Parepare', 'Torble Sea', 'Kawrea')]
    [string] $ErrantryName

    # The type of techniques (besides Basic, and in rare cases Special)
    # that can be learned at the errantry.
    [ValidateRange(2, 6)]
    [int] $TechniqueTypeId
}
