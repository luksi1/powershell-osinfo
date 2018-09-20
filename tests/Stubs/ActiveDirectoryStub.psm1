function Get-ADComputer {
    [OutputType("PSCustomObject")]
    [cmdletbinding()]
    param(
        [string[]] $Identity,
        [string[]] $Filter
    )

    return @{"Name"=$Identity}

}
