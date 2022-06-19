<#
    misc-utils.ps1
        Miscellaneous functions and cmdlets used throughout
        the data generation scripts.
#>

<#
.SYNOPSIS
Displays an warning message.
#>
function WarningMsg {
    $message = $args -join ' '
    Write-Host $message -ForegroundColor Yellow
}


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
Displays an error message and abort the script.
#>
function Abort {
    $message = $args -join ' '
    Write-Host $message -ForegroundColor Red
    exit 1
}


<#
.SYNOPSIS
Creates a hashtable from a collection of objects
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
        [ValidateNotNullOrEmpty()]
        [string]
        $KeyProperty,

        # The property of the input objects to use as values for the hashtable.
        # If not specified, the input objects themselves will be the values.
        [Parameter(Position = 1)]
        [string]
        $ValueProperty
    )

    begin {
        $table = @{}
    }

    process {
        if ([string]::IsNullOrEmpty($ValueProperty)) {
            $table.Add($InputObject.$KeyProperty, $InputObject)
        } else {
            $table.Add($InputObject.$KeyProperty, $InputObject.$ValueProperty)
        }
    }

    end {
        return $table
    }
}


<#
.SYNOPSIS
Gets the information for all applications with the specified name.

.OUTPUTS
Returns `ApplicationInfo` objects representing all applications with the specified name.
Use the `First` switch parameter to only return the first application for each name.
#>
function Get-ApplicationInfo {
    [CmdletBinding()]
    [OutputType([System.Management.Automation.ApplicationInfo])]
    param(
        # The name of the applications for which to get the information.
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        # Indicates that this cmdlet only returns the first application with the specified name.
        [switch]
        $First
    )

    process {
        $appInfo = Get-Command -Name $Name -CommandType Application -ErrorAction Ignore

        if ($null -eq $appInfo) {
            return
        }
        elseif ($First) {
            return $appInfo[0]
        }
        
        return $appInfo
    }
}
