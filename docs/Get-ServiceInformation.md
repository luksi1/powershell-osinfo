---
external help file: OSInfo-help.xml
Module Name: osinfo
online version:
schema: 2.0.0
---

# Get-ServiceInformation

## SYNOPSIS
Get service information

## SYNTAX

```
Get-ServiceInformation [[-ComputerName] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Get service information via the Common Infrastructure Model (CIM)

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-ServiceInformation -Computer MYCOMPUTER
```

## PARAMETERS

### -ComputerName
The name of the computer

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
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
