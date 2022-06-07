<#
    Entity representing an errantry that monsters can go on to learn techniques.
#>
class Errantry {
    [ValidateRange(1, 5)]
    [int] $ErrantryId

    [ValidateSet('Papas', 'Mandy', 'Parepare', 'Torble Sea', 'Kawrea')]
    [string] $ErrantryName
}
