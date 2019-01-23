<#
.SYNOPSIS
    Override the ValideEnumeratedArgumentsAttribute in .NET with our own validator
#>
class ADComputer : System.Management.Automation.ValidateEnumeratedArgumentsAttribute {
    [void]  ValidateElement([object]$argument) {
        try {
            $computerName = Get-ADComputer $argument
            # There is no way to handle a typenotfound error when running pester
            # if the class does not exist. It will throw an error while parsing the class.
            # It makes no difference whether this will get called or not.
            # Maybe this could be mocked? Stubbed?
            #} catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
        } catch {
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
   The parameter name in which we want to add dynamically to our function.
#>
function _setDynamicValidateSet {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)]
        [string] $ParameterName,
        [string] $ParameterSet
    )

    $arraySet = _getDynamicValidateSet
                
    # Create the dictionary
    $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

    # Create the collection of attributes
    $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
    
    # Create and set the parameters' attributes
    $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
    $ParameterAttribute.Position = 1
    if ($ParameterSet) {
        $ParameterAttribute.ParameterSetName = $ParameterSet
    }

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
    # Ex. Get all Active Directory servers
    # (Get-ADComputer -Filter *).
    # Ex. Get a subset of Active Directory servers
    # (Get-ADComputer -Filter 'Name -like "foo*"').Name
    # Ex. Get all files in directory
    # (Get-ChildItem).Name
    # Here we simply use the localhost names for simplicity
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
    [cmdletbinding(DefaultParameterSetName="defaultcredentials")]
    param (
        [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName='cmspasswordfile')]
        [Parameter(ParameterSetName='cmspasswordstring')]
        [Parameter(ParameterSetName='defaultcredentials')]
        [Parameter(ParameterSetName='usernamepassword')]
        [Parameter(ParameterSetName='credentials')]
        [ArgumentCompleter( {
            foreach ( $computer in (Get-ADComputer -filter *).Name ) {
                [System.Management.Automation.CompletionResult]::new($computer, $computer, [System.Management.Automation.CompletionResultType]::ParameterValue, $computer)
            }
        })]
        [ADComputer()]
        [String[]] $ComputerName,
        [Parameter(ParameterSetName='credentials', ValueFromPipelineByPropertyName)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,
        [Parameter(ParameterSetName='usernamepassword', Mandatory, ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName='cmspasswordfile')]
        [Parameter(ParameterSetName='cmspasswordstring')]
        [String[]] $Username,
        [parameter(ParameterSetName='usernamepassword', Mandatory, ValueFromPipelineByPropertyName)]
        [String[]] $Password,
        [Parameter(ParameterSetName='cmspasswordfile', Mandatory, ValueFromPipelineByPropertyName)]
        [System.IO.FileInfo[]] $CMSEncryptedPasswordFile,
        [Parameter(ParameterSetName='cmspasswordstring', Mandatory, ValueFromPipelineByPropertyName)]
        [System.IO.FileInfo[]] $CMSEncryptedPassword
    )

    begin {
        switch ($PSCmdlet.ParameterSetName) {
            "defaultcredentials" {
                if ($ComputerName) { 
                    New-CimSession -ComputerName $ComputerName | Out-Null 
                } else { 
                    New-CimSession | Out-Null 
                }
            }
            "credentials" {
                New-CimSession -ComputerName $ComputerName -Credential $Credential
            }
            "usernamepassword" {
                $mysecurepassword = $Password | ConvertTo-SecureString -AsPlainText -Force
                $Credential = New-Object System.Management.Automation.PSCredential($Username, $mysecurepassword)
                New-CimSession -ComputerName $ComputerName -Credential $Credential
            }
            "cmspasswordfile" {
                $mysecurepassword = ConvertTo-SecureString (Unprotect-CmsMessage -Path $CMSEncryptedPasswordFile) -AsPlainText -Force
                $Credential = New-Object System.Management.Automation.PSCredential($Username, $mysecurepassword)
                New-CimSession -ComputerName $ComputerName -Credential $Credential
            }
            "cmspasswordstring" {
                $mysecurepassword = ConvertTo-SecureString (Unprotect-CmsMessage -Content $CMSEncryptedPassword) -AsPlainText -Force
                $Credential = New-Object System.Management.Automation.PSCredential($Username, $mysecurepassword)
                New-CimSession -ComputerName $ComputerName -Credential $Credential
            }
            Default { throw "no parameter sets were matched"}
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

function Get-DiskInformation {
    [alias("gdi")]
    [cmdletbinding(DefaultParameterSetName="defaultcredentials")]
    param (
        [Parameter(ParameterSetName='credentials', Mandatory, ValueFromPipelineByPropertyName)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,
        [Parameter(ParameterSetName='usernamepassword', Mandatory, ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName='cmspasswordfile', Mandatory, ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName='cmspasswordstring', Mandatory, ValueFromPipelineByPropertyName)]
        [String[]] $Username,
        [parameter(ParameterSetName='usernamepassword', Mandatory, ValueFromPipelineByPropertyName)]
        [String[]] $Password,
        [Parameter(ParameterSetName='cmspasswordfile', Mandatory, ValueFromPipelineByPropertyName)]
        [String[]] $CMSEncryptedPasswordFile,
        [Parameter(ParameterSetName='cmspasswordstring', Mandatory, ValueFromPipelineByPropertyName)]
        [String[]] $CMSEncryptedPassword
    )
    DynamicParam {
        $DynamicParameterName = "ComputerName"
        _setDynamicValidateSet($DynamicParameterName)
    }

    begin {
        # ComputerName will not be in the scope of the module. In other words,
        # you cannot call $ComputerName in your begin{}, process{}, or end{} block.
        # You can though get the variable from the $PSBoundParameters dictionary
        $ComputerName = $PSBoundParameters["ComputerName"]

        # Use a case statement to create our CIM session, with parameters based on
        # our validate sets.
        switch ($PSCmdlet.ParameterSetName) {
            "defaultcredentials" {
                if ($ComputerName) { 
                    New-CimSession -ComputerName $ComputerName | Out-Null 
                } else { 
                    New-CimSession | Out-Null
                }
            }
            "credentials" {
                New-CimSession -ComputerName $ComputerName -Credential $Credential
            }
            "usernamepassword" {
                $mysecurepassword = $Password | ConvertTo-SecureString -AsPlainText -Force
                $usernamepasswordCredential = New-Object System.Management.Automation.PSCredential($Username, $mysecurepassword)
                New-CimSession -ComputerName $ComputerName -Credential $usernamepasswordCredential
            }
            "cmspasswordfile" {
                $password = Unprotect-CmsMessage -Path $CMSEncryptedPasswordFile
                $mysecurepassword = $password | ConvertTo-SecureString -AsPlainText -Force
                $cmspasswordfileCredential = New-Object System.Management.Automation.PSCredential($Username, $mysecurepassword)
                New-CimSession -ComputerName $ComputerName -Credential $cmspasswordfileCredential
            }
            "cmspasswordstring" {
                $mysecurepassword = ConvertTo-SecureString (Unprotect-CmsMessage -Content $CMSEncryptedPassword) -AsPlainText -Force
                $credential = New-Object System.Management.Automation.PSCredential($Username, $mysecurepassword)
                New-CimSession -ComputerName $ComputerName -Credential $credential
            }
            Default { throw "no parameter sets were matched"}
        }
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
