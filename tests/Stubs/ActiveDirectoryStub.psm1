function Get-ADComputer {
    [OutputType("PSCustomObject")]
    [cmdletbinding()]
    param(
        [string[]] $Identity
    )

    return @{"Name"=$Identity}

}
