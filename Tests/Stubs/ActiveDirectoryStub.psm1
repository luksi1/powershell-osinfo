
function Get-ADComputer {

    [cmdletbinding()]
    param(
        [string[]] $Identity
    )

    return @{"Name"=$Identity}

}
