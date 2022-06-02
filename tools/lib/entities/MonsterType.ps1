<#
    Base class containing properties common to all entities representing a monster type.
#>
class MonsterTypeBase {
    [ValidateRange(1, 415)]
    [int] $MonsterTypeId

    # ID of the monster type's primary breed.
    # Must be one of the breeds defined in the 'Breeds' table.
    [ValidateRange(0, 37)]
    [int] $MainBreedId

    # The number of the monster card that is obtained from raising this monster type
    # or encountering it in the wild.
    [ValidateRange(1, 415)]
    [int] $CardNumber

    [ValidateLength(3, 12)]
    [ValidatePattern('^[A-Z][a-z]+(?: ?[A-Z][a-z]+)*$')]
    [string] $MonsterTypeName

    [string] $MonsterTypeDescription
}

<#
    Entity representing a type of monster (combination of main breed and sub breed) with some properties
    containing values that are not needed in the finished data.
#>
class MonsterTypeIntermediate : MonsterTypeBase {
    <#
      ID of the monster type's secondary breed.
      Can be one of the breeds defined in the 'Breeds' table. For special monster types this ID
      will be greater than the largest ID in the 'Breeds' table.
      
      For each breed that has special monster types, the first special monster type will have
      a sub-breed ID of <Highest-Breed-ID> + 1, and is incremented by 1 for each additional special
      monster type.

      The sub-breed ID for special monsters will be set to an empty string in the finished data since
      it is an implementation detail. This also allows a foreign-key to be enforced between this column
      and the 'Breeds' table in generated databases.
    #>
    [ValidateRange(0, [int]::MaxValue)]
    [int] $SubBreedId
}

<#
    Entity representing a type of monster (combination of main breed and sub breed.)
#>
class MonsterType : MonsterTypeBase {
    # The order in which the columns should appear in the finished CSV data.
    static [string[]] $ColumnOrder = @(
        'MonsterTypeId', 'MainBreedId', 'SubBreedId', 'CardNumber',
        'MonsterTypeName', 'MonsterTypeDescription'
    )

    [ValidatePattern('^(?:\d|[1-9]\d|)$')]
    [string] $SubBreedId
}
