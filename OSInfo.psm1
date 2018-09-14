
class ADComputer : System.Management.Automation.ValidateEnumeratedArgumentsAttribute {
    [void]  ValidateElement([object]$argument) {
        try {
            $computerName = Get-ADComputer $argument
            #} catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {  //how do we handle a typenotfound in a catch statement?
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
function Get-DiskInformation {
    [alias("gdi")]
    [cmdletbinding()]
    param (
        [ArgumentCompleter( {
                foreach ( $computer in (Get-ADComputer -filter *).Name ) {
                    [System.Management.Automation.CompletionResult]::new($computer, $computer, [System.Management.Automation.CompletionResultType]::ParameterValue, $computer)
                }
            })]
        [parameter(position = 0, valuefrompipeline, valuefrompipelinebypropertyname)]
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


