Function Get-ADUnsupportedOperatingSystem {

    [cmdletbinding(DefaultParameterSetName='Default')]
    param (
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            ParameterSetName='LTSC',  Mandatory=$true,
            Helpmessage="Enter an array of Operating Systems, accepts wildcards."
        )]
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            ParameterSetName='Client',  Mandatory=$true,
            Helpmessage="Enter an array of Operating Systems."
        )]
        [parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            ParameterSetName='Server', Mandatory=$true,
            Helpmessage="Enter a list of operating systems."
        )]
        [ValidatePattern("^[0-9a-zA-Z\s\*\-{1}\.]+$")]
        [String[]]$OperatingSystem,

        [parameter(
            ValueFromPipelineByPropertyName=$true,
            ParameterSetName='Client', Mandatory=$true, Position=0,
            HelpMessage="Enter a list of Windows 10 Operating System Versions."
        )]
        [ValidatePattern("^[0-9a-zA-Z\s\(\)\.\*]+$")]
        [String[]]$ClientOperatingSystemVersion,

        [parameter(
            ValueFromPipelineByPropertyName=$true,
            ParameterSetName='Server', Mandatory=$true, Position=0,
            HelpMessage="Enter a Server SAC Operating System Version."
        )]
        [ValidatePattern("^[0-9a-zA-Z\s\(\)\.\*]+$")]
        [String[]]$ServerOperatingSystemVersion
    )
    Begin {
        $ModuleRootDir = Split-Path $PSScriptRoot -Parent
        Write-Verbose "ParameterSetName is $($PSCmdlet.ParameterSetName)"
        if ($PSCmdlet.ParameterSetName -eq 'Default') {
            $OSInfo = get-content $ModuleRootDir\bin\OperatingSystem.json -Raw | ConvertFrom-Json
            $OperatingSystemStage = $OSInfo.ServerOperatingSystems + $OSInfo.ClientOperatingSystems
            foreach ($OS in $OperatingSystemStage) {
                $OperatingSystem += $OS
            }
            $Win10VerStage = $OSInfo.Win10OSVersions
            foreach ($version in $Win10VerStage){
                $ClientOperatingSystemVersion += $version
            }
            $ServerVerStage = $OSInfo.ServerOSVersions
            foreach ($version in $ServerVerStage) {
                $ServerOperatingSystemVersion = ("*(16299)")
            }
        }
    }
    Process {
        if ($PSCmdlet.ParameterSetName -eq 'LTSC') {
            foreach ($system in $OperatingSystem) {
                if ((($system -like "Windows Server Standard") -or ($system -like "Windows Server Datacenter"))-and (-not($ServerOperatingSystemVersion))) {
                    Write-Error "Searching for server operating system please also specify ServerOperatingSystemVersion parameter"
                    Return
                }
                elseif (($system -like "Windows 10*") -and (-not($ClientOperatingSystemVersion))) {
                    Write-Error "Searching for Windows 10 operating system please also specify ClientOperatingSystemVersion parameter"
                    Return
                }
            }
        }
        Write-Verbose "Beginning to build all filters for Get-ADComputer Cmdlet"
        #Server Semi-Annual Build Filter
        $ServerSemiAnBuildFilter = $ServerOperatingSystemVersion | ForEach-Object {
            '(' + 'OperatingSystemVersion -like ' + '"' + $_ + '"' + ')' + ' -or'
        }
        $ServerSemiAnBuildFilter = "$ServerSemiAnBuildFilter" -replace "-or$",""

        #Win10 Build Filter
        $Win10BuildFilter = $ClientOperatingSystemVersion | ForEach-Object {
            '(' + 'OperatingSystemVersion -like ' + '"' + $_ + '"' + ')' + ' -or'
        }
        $Win10BuildFilter = "$Win10BuildFilter" -replace "-or$",""
        #Build OS Filter
        $OSFilters = $OperatingSystem | ForEach-Object { '(operatingsystem -like ' + '"' + $_ + '"' + ')' + ' -or' }

        #Add Build Info to Filter
        $AllFilters = $OSFilters | ForEach-Object {
            switch ($_) {
                '(operatingsystem -like "Windows Server Standard") -or' { '(' + ($_ -replace ' -or',' -and ') + '(' + $ServerSemiAnBuildFilter + ')' + ')' + ' -or' }
                '(operatingsystem -like "Windows Server Datacenter") -or' { '(' + ($_ -replace ' -or',' -and ') + '(' + $ServerSemiAnBuildFilter + ')' + ')' + ' -or' }
                '(operatingsystem -like "Windows 10 Home") -or' { '(' + ($_ -replace ' -or',' -and ') + '(' + $Win10BuildFilter + ')' + ')' + ' -or' }
                '(operatingsystem -like "Windows 10 Pro") -or' { '(' + ($_ -replace ' -or',' -and ') + '(' + $Win10BuildFilter + ')' + ')' + ' -or' }
                '(operatingsystem -like "Windows 10 Pro Eduction") -or' { '(' + ($_ -replace ' -or',' -and ') + '(' + $Win10BuildFilter + ')' + ')' + ' -or' }
                '(operatingsystem -like "Windows 10 Enterprise") -or' { '(' + ($_ -replace ' -or',' -and ') + '(' + $Win10BuildFilter + ')' + ')' + ' -or' }
                '(operatingsystem -like "Windows 10 Education") -or' { '(' + ($_ -replace ' -or',' -and ') + '(' + $Win10BuildFilter + ')' + ')' + ' -or' }
                Default {$_}
            }
        }
        $AllFilters = "$AllFilters" -replace "-or$",""
        Write-Verbose "Building filters complete"
        Write-Verbose "Filters are: $($AllFilters)"
        #Build Initial Command
        $Command = 'Get-ADComputer' + ' -Filter ' + '{' + $AllFilters + '}'
        #Add Properties
        $Command = $Command + ' -Properties Name,OperatingSystemVersion,OperatingSystem,OperatingSystemServicePack,lastlogontimestamp'

        Write-Verbose "Beginning scan of unsupported operating systems"
        $EOLmachines = Invoke-Expression -Command $Command
        Write-Verbose "Completed scan of unsupported operating systems"
        #Output EOLMachines
        foreach ($machine in $EOLmachines) {
            [pscustomobject]@{
                Name = $machine.name
                OperatingSystem = $machine.OperatingSystem
                OperatingSystemServicePack = $machine.OperatingSystemServicePack
                OperatingSystemVersion = $machine.OperatingSystemVersion
                lastlogontimestamp = [datetime]::FromFileTime($machine.lastlogontimestamp)
            }
        }
    }
    end{}
}