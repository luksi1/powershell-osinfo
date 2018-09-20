<#
.SYNOPSIS
    Override the ValideEnumeratedArgumentsAttribute in .NET with our own validator
#>
class ADComputer : System.Management.Automation.ValidateEnumeratedArgumentsAttribute {
    [void]  ValidateElement([object]$argument) {
        try {
            $computerName = Get-ADComputer $argument
            # There is no way to handle a typenotfound error when running pester
            # if the class does not exist, it will throw an error while parsing
            # it makes no difference whether this will get called or not
            # maybe this could be mocked?
            #} catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
        }
        catch {
            Write-Error "${argument} does not appear to exist in our Active Directory"
            throw $Error.Message
        }
        if ([string]::isnullorempty($computerName.name)) {
            throw "${argument} returned empty when querying our Active Directory. This should not happen!"
        }
    }
}

<#
.SYNOPSIS Return a dictionary with our validation set
.DESCRIPTION
    Instead of embedding our dynamic validation logic inside the function, we can more easily move it to a private function.
    In this way, we can easily reuse the function *AND* we can mock it!
.PARAMETER ParameterName 
    Simply the parameter name in which we want to add dynamically to our function.
#>
function _setDynamicValidateSet {
    [cmdletbinding()]
    param(
        [string] $ParameterName
    )

    $arraySet = _getDynamicValidateSet
                
    # Create the dictionary
    $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

    # Create the collection of attributes
    $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
    
    # Create and set the parameters' attributes
    $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
    $ParameterAttribute.Position = 1

    # Add the attributes to the attributes collection
    $AttributeCollection.Add($ParameterAttribute)

    # Generate and set the ValidateSet 
    $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arraySet)

    # Add the ValidateSet to the attributes collection
    $AttributeCollection.Add($ValidateSetAttribute)

    # Create and return the dynamic parameter
    $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string[]], $AttributeCollection)
    $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
    return $RuntimeParameterDictionary
}

<#
.SYNOPSIS Return an array set of strings, which we will use as our "ValidateSet"
.DESCRIPTION
    By using a function to get our array, we can then mock this function for our Pester tests.
#>
function _getDynamicValidateSet {
    # insert code here
    # this should return an array
    @("localhost", $env:COMPUTERNAME)
}

<#
.SYNOPSIS
    Get service information from the Computer Information Model (CIM)
.PARAMETER ComputerName
    A remote computer name to query service information
.OUTPUTS
    A PSCustomObject with "State","Description","ComputerName","ServiceName","StartupType","ServiceAccount"
.EXAMPLE
    Get-ServiceInformation -ComputerName "Foo"
.EXAMPLE 
    "foo" | Get-ServiceInformation
.EXAMPLE
    Get-ServiceInformation
#>
function Get-ServiceInformation {
    [alias("gsi")]
    [cmdletbinding()]
    param (
        [parameter(position = 0, valuefrompipeline, valuefrompipelinebypropertyname)]
        [ArgumentCompleter( {
                foreach ( $computer in (Get-ADComputer -filter *).Name ) {
                    [System.Management.Automation.CompletionResult]::new($computer, $computer, [System.Management.Automation.CompletionResultType]::ParameterValue, $computer)
                }
            })]
        [adcomputer()]
        [string[]] $ComputerName
    )

    begin { 
        if ($ComputerName) { 
            New-CimSession -ComputerName $ComputerName | Out-Null
        }
        else {
            New-CimSession | Out-Null
        }
    }

    process {
        Get-CimSession | Get-CimInstance -ClassName Win32_Service |
            Select-Object -Property @{N = 'DisplayName'; E = {$_.DisplayName}},
        @{N = 'State'; E = {$_.State}},
        @{N = 'Description'; E = {$_.Description}},
        @{N = 'ComputerName'; E = {$ComputerName}},
        @{N = 'ServiceName'; E = {$_.Name}},
        @{N = 'StartupType'; E = {$_.StartMode}},
        @{N = 'ServiceAccount'; E = {$_.StartName}}
    }

    end { Get-CimSession | Remove-CimSession  }

}

<#
.SYNOPSIS
    Get disk information from the Computer Information Model (CIM)
.PARAMETER ComputerName
    A remote computer name to query disk information
.OUTPUTS
    A PSCustomObject with "SizeMB","FreeSizeMB","PercentFree","ComputerName"
.EXAMPLE
    Get-DiskInformation -ComputerName "Foo"
.EXAMPLE
    "foo" | Get-DiskInformation
.EXAMPLE
    Get-DiskInformation
#>
function Get-DiskInformation {
    [alias("gdi")]
    [cmdletbinding()]
    param()
    DynamicParam {
        $DynamicParameterName = "ComputerName"
        _setDynamicValidateSet($DynamicParameterName)
    }

    begin {
        # You need to bind the dynamic parameter to a variable!
        $ComputerName = $PsBoundParameters[$DynamicParameterName]

        # If computername is not set, then we need to get a CIM session locally
        if ($ComputerName) { 
            New-CimSession -ComputerName $ComputerName | Out-Null
        }
        else {
            New-CimSession | Out-Null
        }
        "computername = $ComputerName"
    }

    process {
        Get-CimSession | Get-CimInstance -ClassName Win32_logicaldisk |
            Select-Object -Property Name,
        @{N = 'SizeMB'; E = {$_.Size / 1mb}},
        @{N = 'FreeSizeMB'; E = {$_.FreeSpace / 1mb}},
        @{N = 'PercentFree'; E = {
                $percent = [Math]::Round(($_.FreeSpace / $_.Size) * 100, 2)
                "${percent}%"
            }
        },
        @{N = 'ComputerName'; E = {$ComputerName}}
    }

    end { Get-CimSession | Remove-CimSession }
}


