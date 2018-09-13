Import-Module -force ${PSScriptRoot}\OSInfo.psm1

Describe 'OSInfo' {

    Mock -CommandName Get-ADComputer -ModuleName OSInfo { return @{
        Name = "Foo"
    }}
    
    Mock -CommandName New-CimSession -ModuleName OSInfo { return @{
        Id = "1";
        Name = "CimSession1";
        InstanceId = "1234";
        ComputerName = "Foo";
        Protocol = "DCOM"
    }}

    Mock -CommandName Get-CimSession -ModuleName OSInfo { return @{
        Id = "1";
        Name = "CimSession1";
        InstanceId = "1234";
        ComputerName = "Foo";
        Protocol = "DCOM"
    }}

    Context "Get Service Information" {
        
        Mock -CommandName Get-CimInstance -ModuleName OSInfo { return @{
            ProcessId = 0;
            Name = "Foo";
            StartMode = "Automatic";
            State = "Running";
            Status = "OK";
            ExitCode = 0;
            StartName = "company\foo";
            Description = "This is my service";
            DisplayName = "Foo";
        }}

        $services = Get-ServiceInformation -ComputerName "Foo"
    
        It "returns the correct values" {   
            $services.DisplayName | Should Be "Foo"
        }
    }
    

}

