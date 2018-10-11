---
external help file: OSInfo-help.xml
Module Name: OSInfo
online version:
schema: 2.0.0
---

# Get-DiskInformation

## SYNOPSIS
Get Disk information

## SYNTAX

### defaultcredentials (Default)
```
Get-DiskInformation [[-ComputerName] <String[]>] [<CommonParameters>]
```

### credentials
```
Get-DiskInformation [-Credential <SecureString[]>] [[-ComputerName] <String[]>] [<CommonParameters>]
```

### cmspasswordstring
```
Get-DiskInformation [-Username <String[]>] -CMSEncryptedPassword <FileInfo[]> [[-ComputerName] <String[]>]
 [<CommonParameters>]
```

### cmspasswordfile
```
Get-DiskInformation [-Username <String[]>] -CMSEncryptedPasswordFile <FileInfo[]> [[-ComputerName] <String[]>]
 [<CommonParameters>]
```

### usernamepassword
```
Get-DiskInformation -Username <String[]> -Password <String[]> [[-ComputerName] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Hämta ut information ifrån Command Infrastructure Model (CIM)

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
Datornamnet


```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CMSEncryptedPassword
Ett CMS krypterat lösenord

```yaml
Type: FileInfo[]
Parameter Sets: cmspasswordstring
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -CMSEncryptedPasswordFile
En fil med ett krypterat CMS lösenord

```yaml
Type: FileInfo[]
Parameter Sets: cmspasswordfile
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Credential
Ett credential objekt

```yaml
Type: SecureString[]
Parameter Sets: credentials
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Password
Lösenord

```yaml
Type: String[]
Parameter Sets: usernamepassword
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Username
Användarenamnet

```yaml
Type: String[]
Parameter Sets: cmspasswordstring, cmspasswordfile
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String[]
Parameter Sets: usernamepassword
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
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
