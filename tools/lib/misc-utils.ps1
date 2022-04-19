<#
    misc-utils.ps1
        Miscellaneous functions and cmdlets used throughout
        the data generation scripts.
#>

<#
.SYNOPSIS
Displays an error message.
#>
function ErrorMsg {
    $message = $args -join ' '
    Write-Host $message -ForegroundColor Red
}


<#
.SYNOPSIS
Display an error message and abort the script.
#>
function Abort {
    $message = $args -join ' '
    Write-Host $message -ForegroundColor Red
    exit 1
}


<#
.SYNOPSIS
Create a hashtable from a collection of objects
using the specified properties as the keys and values.
#>
function ConvertTo-Hashtable {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        # The objects used to create the hashtable.
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNull()]
        [PSObject]
        $InputObject,

        # The property of the input objects to use as keys for the hashtable.
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNull()]
        [object]
        $KeyProperty,

        # The property of the input objects to use as values for the hashtable.
        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNull()]
        [object]
        $ValueProperty
    )

    begin {
        $table = @{}
    }

    process {
        $table.Add($InputObject.$KeyProperty, $InputObject.$ValueProperty)
    }

    end {
        return $table
    }
}
