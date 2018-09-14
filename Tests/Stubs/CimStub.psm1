
function New-CimSession {
    [cmdletbinding()]
    param(
        [string[]] $ComputerName
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand

}
function Get-CimSession {

    [cmdletbinding()]
    param(
        [string[]] $ComputerName
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand

}
function Remove-CimSession {
    [cmdletbinding()]
    param(
        [parameter(mandatory, valuefrompipeline)]
        [string[]] $CimSession
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand

}
function Get-CimInstance {

    [cmdletbinding()]
    param(
        [parameter(mandatory, valuefrompipeline, valuefrompipelinebypropertyname)]
        [string[]] $ClassName
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand

}