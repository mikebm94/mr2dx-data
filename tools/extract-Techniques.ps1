#!/usr/bin/env pwsh

<#
.SYNOPSIS
Extracts raw data for the techniques available to each monster breed
from the game's technique data files.
#>

[CmdletBinding()]
param()


$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'lib/file-utils.ps1')
. (Join-Path $PSScriptRoot 'lib/entities/Breed.ps1')
. (Join-Path $PSScriptRoot 'lib/entities/Technique.ps1')
. (Join-Path $PSScriptRoot 'lib/entities/TechniqueRange.ps1')

# The ranges that techniques can be performed in.
$TechniqueRanges =
    Import-Mr2dxDataFileCsv IntermediateData TechniqueRanges |
    Sort-Object -Property { [int]$PSItem.TechniqueRangeId } |
    ForEach-Object { [TechniqueRangeIntermediate]$PSItem }


function Main {
    [CmdletBinding()]
    param()

    Write-Host 'Extracting technique data from MR2DX game files ...'

    $breeds =
        Import-Mr2dxDataFileCsv IntermediateData Breeds |
        Sort-Object -Property { [int]$PSItem.BreedId } |
        ForEach-Object { [BreedIntermediate]$PSItem }

    $techniques = $breeds | Get-BreedTechnique
    Write-Host "Extracted $( $techniques.Count ) technique(s)."
    
    $outputFilePath = $techniques | Export-Mr2dxDataFileCsv ExtractedData Techniques
    Write-Host "Saved extracted technique data to '${outputFilePath}'."
}


<#
.SYNOPSIS
Gets the techniques available to a monster breed.
#>
function Get-BreedTechnique {
    [CmdletBinding()]
    [OutputType([TechniqueExtracted])]
    param(
        # The monster breed of which to get the available techniques.
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNull()]
        [BreedIntermediate]
        $Breed
    )

    begin {
        $techniqueDefinitionPattern = @'
(?msx)
^/ \s* WAZA_DATA_0*(?<TechniqueNumber>\d+): \s* (?:;.*?)?
^/ \s* NAME_START \s* (?:;.*?)?
^  \s* .*? \s*
^/ \s* NAME_END \s* (?:;.*?)?
^/ \s* TYPE_RANGE     \s+ (?<TechniqueTypeFlag>[A-Z_]+)    \s* ,
                      \s* (?<TechniqueRangeFlag>[A-Z_]+)   \s* (?:;.*?)?
^/ \s* ATTR_PWS       \s+ (?<TechniqueNatureFlag>[A-Z_]+)  \s* ,
                      \s* (?<ForceTypeFlag>[A-Z_]+)        \s* (?:;.*?)?
^/ \s* MAXHIT         \s+ \d+                              \s* (?:;.*?)?
^/ \s* HIT_PER        \s+ (?<HitPercent>-?\d+)             \s* (?:;.*?)?
^/ \s* HP_DMGVAL      \s+ (?<Damage>\d+)                    \s* (?:;.*?)?
^/ \s* GUTS_DMGVAL    \s+ (?<Withering>\d+)                \s* (?:;.*?)?
^/ \s* CR_PER         \s+ (?<Sharpness>\d+)                \s* (?:;.*?)?
^/ \s* GUTS_COST      \s+ (?<GutsCost>\d+)                 \s* (?:;.*?)?
^/ \s* GUTS_DRAIN     \s+ (?<GutsDrain>\d+)                \s* (?:;.*?)?
^/ \s* HP_DRAIN       \s+ (?<HpDrain>\d+)                  \s* (?:;.*?)?
^/ \s* HP_RECOVERY    \s+ (?<HpRecovery>\d+)               \s* (?:;.*?)?
^/ \s* SELF_DMGVAL    \s+ (?<SelfDamageMiss>\d+)           \s* (?:;.*?)?
^/ \s* SUICIDE_DMGVAL \s+ (?<SelfDamageHit>\d+)            \s* (?:;.*?)?
^/ \s* END_OF_DATA \s* (?:;.*?)?
^/; \s* (?:;.*?)?
'@

        # The data points to extract from the technique definitions. These are the fields of the
        # `TechniqueExtracted` objects populated by the values of capture groups with the same name.
        $dataPoints = @(
            'TechniqueTypeFlag', 'ForceTypeFlag', 'TechniqueNatureFlag', 'HitPercent', 'Damage',
            'Withering', 'Sharpness', 'GutsCost', 'GutsDrain', 'HpDrain', 'HpRecovery',
            'SelfDamageHit', 'SelfDamageMiss'
        )
    }

    process {
        $dataFileKey = 'Techniques{0}' -f $Breed.Initials
        $techniqueData = Get-Mr2dxDataFileContent GameFiles $dataFileKey

        $dataFilePath = (Get-ManifestFileInfo GameFiles $dataFileKey).FullPath
        
        Write-Host (
            "Extracting technique data for breed '{0}' from '{1}' ..." -f $Breed.BreedName, $dataFilePath
        )

        <#
          The technique table is a section in a monster breed's technique data file that declares the
          techniques that are actually available in the game and what range and slot they exist in.

          Get a collection of `TechniqueExtracted` objects with the `TechniqueRangeId`, `Slot`,
          and `TechniqueNumber` fields populated based on the contents of the technique table.
          Then, create a dictionary mapping the technique numbers of the techniques to the techniques
          themselves. The dictionary will be used when parsing the technique definitions
          to determine if the definition corresponds to a technique actually available in the game.
        #>
        $techniqueTable =
            Get-DeclaredTechnique $techniqueData |
            ConvertTo-Hashtable -KeyProperty TechniqueNumber
        
        $matchInfo = $techniqueData | Select-String $techniqueDefinitionPattern -AllMatches
    
        if (-not $matchInfo) {
            throw 'Could not find technique definitions.'
        }

        # Use this to check whether we found definitions
        # for all of the techniques declared in the technique table.
        $techniqueCount = 0
        
        foreach ($match in $matchInfo.Matches) {
            $technique = $techniqueTable[($match.Groups['TechniqueNumber'].Value -as [int])]

            if ($null -eq $technique) {
                # Technique was not declared in the technique table
                # and so is not available in the game, skip it.
                continue
            }

            $technique.BreedId = $Breed.BreedId
            $technique.TechniqueId = [TechniqueExtracted]::GetTechniqueId(
                $technique.BreedId, $technique.TechniqueNumber
            )
            
            foreach ($dataPoint in $dataPoints) {
                $technique.$dataPoint = $match.Groups[$dataPoint].Value
            }

            $techniqueCount++
            Write-Output $technique
        }

        if ($techniqueCount -lt $techniqueTable.Count) {
            $missingDefinitions = $techniqueTable.Count - $techniqueCount
            throw "Missing definitions for {0} out of {1} declared techniques." `
                  -f $missingDefinitions, $techniqueTable.Count
        }
    }
}


<#
.SYNOPSIS
Gets the techniques declared in the technique table of a breed's technique data file.

.DESCRIPTION
The `TechniqueRangeId` and `Slot` fields will be populated based on where in the technique table
that the technique was defined. The `TechniqueNumber` field will also be populated.
#>
function Get-DeclaredTechnique {
    [CmdletBinding()]
    [OutputType([TechniqueExtracted])]
    param(
        # The content of a monster breed's technique data file.
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]
        $TechniqueData
    )

    begin {
        # Build the regular expression used to parse the technique table.

        $techniqueTablePatternSb = [System.Text.StringBuilder]::new('(?msx)', 1024)

        # The technique table consists of four ranges, each with the same structure.
        # Create a template for the pattern used to match them.
        $rangePatternTemplate = @'
^/; .*?
^/ \s* dw \s* {0}\s*, \s* {1}\s*, \s* {2} \s*
^/ \s* dw \s* {3}\s*, \s* {4}\s*, \s* {5} \s*
'@

        # There are 6 slots in each range that can contain a technique or a dummy value.
        # Create the patterns used to match these slots, with groups named '{range flag}_{slot number}'
        # used to capture the number of the techniques in the slots.
        $slotPatternTemplate = 'WAZA_DATA_(?<{0}_{1}>DMY|0*\d+)'

        foreach ($range in $TechniqueRanges) {
            $slotPatterns = 1..[Technique]::TechniqueSlotsPerRange | ForEach-Object {
                $slotPatternTemplate -f $range.Flag, $PSItem
            }

            # Plug the slot patterns into the range pattern template
            # and append the result to the technique table pattern.
            $techniqueTablePatternSb.AppendFormat($rangePatternTemplate, $slotPatterns) | Out-Null
        }

        $techniqueTablePattern = $techniqueTablePatternSb.ToString()
    }

    process {
        $matchInfo = $TechniqueData | Select-String $techniqueTablePattern
        
        if (-not $matchInfo) {
            throw 'Could not find technique table.'
        }

        $match = $matchInfo.Matches[0]

        foreach ($range in $TechniqueRanges) {
            $slot = 1

            for ($i = 1; $i -le [Technique]::TechniqueSlotsPerRange; $i++) {
                $slotGroupName = "{0}_{1}" -f $range.Flag, $i
                $techniqueNumber = $match.Groups[$slotGroupName].Value

                if ($techniqueNumber -eq 'DMY') {
                    # Slot contains a dummy value, skip it.
                    continue
                }

                $technique = [TechniqueExtracted]::new()
                $technique.TechniqueRangeId = $range.TechniqueRangeId
                $technique.Slot = $slot
                $technique.TechniqueNumber = $techniqueNumber

                $slot++
                Write-Output $technique
            }
        }
    }
}


Main
