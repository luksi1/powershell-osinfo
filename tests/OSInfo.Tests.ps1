Import-Module -force ${PSScriptRoot}\..\OSInfo.psm1
Import-Module -force ${PSScriptRoot}\Stubs\CimStub.psm1
Import-Module -force ${PSScriptRoot}\Stubs\ActiveDirectoryStub.psm1
Import-Module -force ${PSScriptRoot}\Stubs\CMSStub.psm1

Describe 'OSInfo' {
    
    Mock -CommandName Get-ADComputer { @{Name="Foo"} }
    Mock -CommandName New-CimSession -ModuleName OSInfo { $true }
    Mock -CommandName Get-CimSession -ModuleName OSInfo { @{ 
        'Id'=1;
        'Name'='CimSession1';
        'ComputerName'='Foo';
        'Protocol'='DCOM'
    }}
    Mock -CommandName Remove-CimSession -ModuleName OSInfo { $true }
    Mock -CommandName _getDynamicValidateSet -ModuleName OSInfo -MockWith { @("Foo") }
    Mock -CommandName Unprotect-CmsMessage -ModuleName OSInfo -MockWith {"abc123"}

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

        Describe 'using a default kerberos token' {

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

        Describe 'using a credential' {

            $mysecurepassword = "abc123" | ConvertTo-SecureString -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential("luksi1", $mysecurepassword)

            $disk = Get-DiskInformation -ComputerName "Foo" -Credential $Credential

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

        Describe 'with a username / password' {

            $disk = Get-DiskInformation -ComputerName "Foo" -Username "luksi1" -Password "abc123"

            It "returns the correct disk size" {
                $disk.SizeMB | Should Be 227654.99609375
            }
            It "returns the correct free size in megabytes" {
                $disk.FreeSizeMb | Should Be 140933.40625
            }
            It "returns the correct percentage of free space" {
                $disk.PercentFree | Should Be "61.91%"
            }
            It "returns the correct computer name" {
                $disk.ComputerName | Should Be "Foo"
            }
        }

        Describe 'with a CMS password file' {

            $disk = Get-DiskInformation -ComputerName "Foo" -Username "luksi1" -CMSEncryptedPasswordFile "${PSScriptRoot}\Files\password.txt"

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

        Describe 'with a CMS encrypted string' {

            $disk = Get-DiskInformation -ComputerName "Foo" -Username "luksi1" -CMSEncryptedPassword "super duper encrypted string"

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

        Describe 'using a default kerberos token' {
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

        Describe 'using a credential' {
            $mysecurepassword = "abc123" | ConvertTo-SecureString -AsPlainText -Force
            $credential = New-Object System.Management.Automation.PSCredential("luksi1", $mysecurepassword)
            $service = Get-ServiceInformation -ComputerName "Foo" -Credential $credential

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
        Describe 'using a username/password' {
            $service = Get-ServiceInformation -ComputerName "Foo" -Username "luksi1" -Password "abc123"

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
        Describe 'using a CMS file' {
            $service = Get-ServiceInformation -ComputerName "Foo" -Username "luksi1" -CMSEncryptedPasswordFile "${PSScriptRoot}\Files\password.txt"

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
        Describe 'using a CMS password string' {
            $service = Get-ServiceInformation -ComputerName "Foo" -Username "luksi1" -CMSEncryptedPassword "super duper encrypted string"

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

    Remove-Module CimStub
    Remove-Module ActiveDirectoryStub
}

