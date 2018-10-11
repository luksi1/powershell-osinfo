---
external help file: OSInfo-help.xml
Module Name: OSInfo
online version:
schema: 2.0.0
---

# Get-ServiceInformation

## SYNOPSIS
Hämta ut service information ifrån CIM (Computer Infrastructure Model)

## SYNTAX

### defaultcredentials (Default)
```
Get-ServiceInformation [[-ComputerName] <String[]>] [<CommonParameters>]
```

### usernamepassword
```
Get-ServiceInformation [[-ComputerName] <String[]>] -Username <String[]> -Password <String[]>
 [<CommonParameters>]
```

### cmspasswordstring
```
Get-ServiceInformation [[-ComputerName] <String[]>] [-Username <String[]>] -CMSEncryptedPassword <FileInfo[]>
 [<CommonParameters>]
```

### cmspasswordfile
```
Get-ServiceInformation [[-ComputerName] <String[]>] [-Username <String[]>]
 -CMSEncryptedPasswordFile <FileInfo[]> [<CommonParameters>]
```

### credentials
```
Get-ServiceInformation [[-ComputerName] <String[]>] [-Credential <SecureString[]>] [<CommonParameters>]
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
Datornamnet

```yaml
Type: String[]
Parameter Sets: defaultcredentials, usernamepassword, cmspasswordstring, cmspasswordfile
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String[]
Parameter Sets: credentials
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
En credential objekt

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

### -Username
Användarenamnet

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

```yaml
Type: String[]
Parameter Sets: cmspasswordstring, cmspasswordfile
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Password
Lösenordet

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

### -CMSEncryptedPasswordFile
{{Fill CMSEncryptedPasswordFile Description}}

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String[]

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
