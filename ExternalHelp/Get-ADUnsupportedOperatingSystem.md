---
external help file: ADUnsupportedOperatingSystem-help.xml
Module Name: ADUnsupportedOperatingSystem
online version:
schema: 2.0.0
---

# Get-ADUnsupportedOperatingSystem

## SYNOPSIS
This function gets all or specific AD computer objects from the directory which are no longer are within support.

## SYNTAX

### Default (Default)
```
Get-ADUnsupportedOperatingSystem [<CommonParameters>]
```

### Server
```
Get-ADUnsupportedOperatingSystem -OperatingSystem <String[]> [-ServerOperatingSystemVersion] <String[]>
 [<CommonParameters>]
```

### Client
```
Get-ADUnsupportedOperatingSystem -OperatingSystem <String[]> [-ClientOperatingSystemVersion] <String[]>
 [<CommonParameters>]
```

### LTSC
```
Get-ADUnsupportedOperatingSystem -OperatingSystem <String[]> [<CommonParameters>]
```

## DESCRIPTION
This function gets all or specific AD computer objects from the directory which are no longer are within support.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-ADUnsupportedOperatingSystem
```

Gets all Windows unsupported operating systems

### Example 2
```powershell
PS C:\> Get-ADUnsupportedOperatingSystem -OperatingSystem "Windows Server Datacenter" -ServerOperatingSystemVersion "10.0 (16299)"
```

Searches the directory for a specific Windows Server semi-annual channel version

### Example 3
```powershell
PS C:\> Get-ADUnsupportedOperatingSystem -OperatingSystem "Windows 10 Enterprise" -ClientOperatingSystemVersion "10.0 (15063)"
```

Searches the directory for a specific Windows Client semi-annual channel version

### Example 4
```powershell
PS C:\> Get-ADUnsupportedOperatingSystem -OperatingSystem "Windows Server 2008*"
```

Searches the directory for all types of a specified operating system

## PARAMETERS

### -OperatingSystem
Enter a list of operating systems, accepts wildcards.

```yaml
Type: String[]
Parameter Sets: Server, Client, LTSC
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -ServerOperatingSystemVersion
Enter a Server SAC Operating System Version.

```yaml
Type: String[]
Parameter Sets: Server
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Win10OperatingSystemVersion
Enter a list of Windows 10 Operating System Versions.

```yaml
Type: String[]
Parameter Sets: Client
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String[]

## OUTPUTS

### System.Management.Automation.PSCustomObject
## NOTES

## RELATED LINKS
