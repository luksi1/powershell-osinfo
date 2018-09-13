---
external help file: OSInfo-help.xml
Module Name: osinfo
online version:
schema: 2.0.0
---

# Get-DiskInformation

## SYNOPSIS
Get Disk information

## SYNTAX

```
Get-DiskInformation [-ComputerName] <String[]> [<CommonParameters>]
```

## DESCRIPTION
Get disk information from the Command Infrastructure Model (CIM)

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-DiskInformation -ComputerName MYCOMPUTER
```

### Example 2
```powershell
PS C:\> "MYCOMPUTER" | Get-DiskInformation
```

### Example 3
```powershell
PS C:\> "MYCOMPUTER1","MYCOMPUTER2" | Get-DiskInformation
```

## PARAMETERS

### -ComputerName
The name of the computer


```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String[]

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
