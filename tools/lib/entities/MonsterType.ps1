<#
    Entity representing a type of monster (combination of main breed and sub breed.)
#>
class MonsterType {
    [ValidateRange(1, 415)]
    [int] $MonsterTypeId

    # ID of the monster type's primary breed.
    # Must be one of the breeds defined in the 'Breeds' table.
    [ValidateRange(0, 37)]
    [int] $MainBreedId

    <#
      ID of the monster type's secondary breed.
      Can be one of the breeds defined in the 'Breeds' table. For special monster types this ID
      will be greater than the largest ID in the 'Breeds' table.
      
      For each breed that has special monster types, the first special monster type will have
      a SubBreedID of <Highest-Breed-ID> + 1, and is incremented by 1 for each additional special
      monster type.

      TODO: Find a way to import NULL values from CSV into an SQLite database so that a foreign key
      constraint can be enforced between this column and the 'Breeds' table.
    #>
    [ValidateRange(0, [int]::MaxValue)]
    [int] $SubBreedId

    # The number of the monster card that is obtained from raising this monster type
    # or encountering it in the wild.
    [ValidateRange(1, 415)]
    [int] $CardNumber

    [ValidateLength(3, 12)]
    [ValidatePattern('^[A-Z][a-z]+(?: ?[A-Z][a-z]+)*$')]
    [string] $MonsterTypeName

    [string] $MonsterTypeDescription
}
