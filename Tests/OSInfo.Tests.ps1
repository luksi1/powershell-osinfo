Import-Module -force ${PSScriptRoot}\..\OSInfo.psm1
Import-Module -force ${PSScriptRoot}\Stubs\CimStub.psm1
Import-Module -force ${PSScriptRoot}\Stubs\ActiveDirectoryStub.psm1

# With Powershell Core on Linux, these modules do not exist
# and therefore cannot be used with microsoft/powershell:latest Docker image.
# So we'll fake them here to avoid a CommandNotFoundException, while running Validate-Command
# Perhaps there is a way to not run Validate-Command in Pester?
# Regardless, Powershell Core is still running our validators, even though we have mocked Get-ADComputer
# So these are commented out for the time being.
# function Get-ADComputer {}
# function New-CimSession {}
# function Get-CimSession {}
# function Remove-CimSession {}
# function Get-CimInstance {}

Describe 'OSInfo' {
    
    Mock Get-ADComputer { @{Name="Foo"} }
    Mock New-CimSession -ModuleName OSInfo -MockWith { New-MockObject -Type Microsoft.Management.Infrastructure.CimSession }
    Mock Get-CimSession -ModuleName OSInfo -MockWith { New-MockObject -Type Microsoft.Management.Infrastructure.CimSession }
    Mock Remove-CimSession -ModuleName OSInfo { $true }

    Context "get disk information" {

        Mock -CommandName Get-CimInstance -ParameterFilter { $ClassName -eq "Win32_logicaldisk" } -ModuleName OSInfo  { @{
            Size = 238713565184;
            DeviceId = "C:";
            Name = "Foo";
            DriveType = 3;
            ProviderName = $null;
            VolumeName = "Windows";
            FreeSpace = 147779387392;
        }}

        $disk = Get-DiskInformation -ComputerName "Foo"

        It "returns the correct disk size" {
            $disk.SizeMB | Should Be 227654.99609375
        }
        It "returns the correct free size in megabytes" {
            $disk.FreeSizeMb | Should Be 140933.40625
        }
        It "return the correct percentage of free space" {
            $disk.PercentFree | Should Be "61.91%"
        }
        It "return the correct computer name" {
            $disk.ComputerName | Should Be "Foo"
        }
    }

    Context "get service information" {

        Mock -CommandName Get-CimInstance -ModuleName OSInfo -ParameterFilter { $ClassName -eq "Win32_Service" } { @{
            ProcessId = 0;
            Name = "Foo";
            StartMode = "Automatic";
            State = "Running";
            Status = "OK";
            StartName = "company\foo";
            Description = "This is my service";
            DisplayName = "Foo"
        }}

        $service = Get-ServiceInformation -ComputerName "Foo"

        It "returns the correct computer name" {
            $service.ComputerName | Should Be "Foo"
        }
        It "returns the correct display name" {
            $service.DisplayName | Should Be "Foo"
        }
        It "returns the correct service name" {
            $service.ServiceName | Should Be "Foo"
        }
        It "returns the correct startup type" {
            $service.StartupType | Should Be "Automatic"
        }
        It "returns the correct service account" {
            $service.ServiceAccount | Should Be "company\foo"
        }
        It "returns the correct state" {
            $service.state | Should Be "Running"
        }
        It "returns the correct description" {
            $service.description | Should Be "This is my service"
        }
    }
}

