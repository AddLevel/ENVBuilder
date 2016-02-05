Function Set-ENVconfiguration{

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformation()]
        [hashtable] $ConfigurationDataFile
    )

    Write-Verbose "  Running Set-ENVconfiguration"

    #Load Configuration from ConfigurationDataFile:
    [string]$Source        = $ConfigurationDataFile.AllNodes.ENVSource
    [string]$AdminPassword = $ConfigurationDataFile.AllNodes.ENVlocalpassword

    $Pass              = ConvertTo-SecureString $AdminPassword -AsPlainText -Force 
    $DomainAdminCred   = New-Object System.Management.Automation.PSCredential ("DEMO\Administrator", $Pass) #TODO: Change DomainName
    $SafeModeAdminCred = New-Object System.Management.Automation.PSCredential ("Administrator", $Pass)

    Configuration Contracts
    {
        Param(
            [PSCredential]
            $domainCred,

            [PSCredential]
            $safemodeCred
        )

        #NOTE: Every Module must be constant, DSC Bug?!
        Import-DscResource –ModuleName PSDesiredStateConfiguration
        Import-DscResource -ModuleName xComputerManagement
        Import-DscResource -ModuleName xPendingReboot
        Import-DscResource -ModuleName xHyper-V
        Import-DscResource -ModuleName xActiveDirectory
        Import-DscResource -ModuleName xNetworking
        Import-DscResource -ModuleName xDhcpServer

        node $AllNodes.Where{$_.Role -match "HyperV"}.NodeName
        {
            #TODO: Get The localhost parameters...
            If ($Node.NodeOS -match "Server")
            {
                # Install the Hyper-V role (Only on server)
                WindowsFeature HyperV
                {
                   Ensure = "Present"
                   Name   = "Hyper-V"
                }
            
            }

            # Create the virtual switch
            xVMSwitch "$($Node.SwitchName)Switch"
            {
                Ensure = "Present"
                Name   = $Node.SwitchName
                Type   = $Node.SwitchType
            }

            # Check for Parent VHD file
            File ParentVHDFile
            {
                Ensure = "Present"
                DestinationPath = "$VMFolder\Templates\W2016.vhdx" #TODO: Check for all templates!
                Type = "File"            
            }

            # Check the destination VHD folder
            File VHDFolder
            {
                Ensure = "Present"
                DestinationPath = "$VMFolder"
                Type = "Directory"
            }

            #Build all VMs:
            $AllVMs = $AllNodes.Where{$_.IsVM -eq $true}
            ForEach ($vm in $AllVMs){
    
                File "$($vm.NodeName)Directory"
                {
                    Ensure = "Present"
                    DestinationPath = "$VMFolder\$($vm.NodeName)\Virtual Hard Disks"
                    Type = "Directory"
                }

                If ($vm.UseTemplate -eq "W2016")
                {
                    xVhd "$($vm.NodeName)Vhdx"
                    {
                        Ensure = "Present"
                        Name   = "$($vm.NodeName)OSDrive"
                        Path   = "$VMFolder\$($vm.NodeName)\Virtual Hard Disks"
                        ParentPath = "$VMFolder\Templates\W2016.vhdx"
                        Generation = "Vhdx"
                    }           
                }
                ElseIf ($vm.UseTemplate -eq "W2012R2")
                {
                    xVhd "$($vm.NodeName)Vhdx"
                    {
                        Ensure = "Present"
                        Name   = "$($vm.NodeName)OSDrive"
                        Path   = "$VMFolder\$($vm.NodeName)\Virtual Hard Disks"
                        ParentPath = "$VMFolder\Templates\W2012R2.vhdx"
                        Generation = "Vhdx"
                    }           
                }
                ElseIf ($vm.UseTemplate -eq "W10")
                {
                    xVhd "$($vm.NodeName)Vhdx"
                    {
                        Ensure = "Present"
                        Name   = "$($vm.NodeName)OSDrive"
                        Path   = "$VMFolder\$($vm.NodeName)\Virtual Hard Disks"
                        ParentPath = "$VMFolder\Templates\W10.vhdx"
                        Generation = "Vhdx"
                    }           
                }
                ElseIf ($vm.UseTemplate -eq "NANO")
                {
                    xVhd "$($vm.NodeName)Vhdx"
                    {
                        Ensure = "Present"
                        Name   = "$($vm.NodeName)OSDrive"
                        Path   = "$VMFolder\$($vm.NodeName)\Virtual Hard Disks"
                        ParentPath = "$VMFolder\Templates\NANO.vhdx"
                        Generation = "Vhdx"
                    }           
                }
                Else{
                    xVhd "$($vm.NodeName)Vhdx"
                    {
                        Ensure = "Present"
                        Name   = "$($vm.NodeName)OSDrive"
                        Path   = "$VMFolder\$($vm.NodeName)\Virtual Hard Disks"                    
                        Generation = "Vhdx"
                    }  
                }


                If ($vm.Generation -eq 1) #TODO: this is ugly... but hey, it works!
                {
                    xVMHyperV "$($vm.NodeName)vm"
                    {
                        Ensure          = "Present"
                        Name            = "$($vm.NodeName)"
                        VhdPath         = "$VMFolder\$($vm.NodeName)\Virtual Hard Disks\$($vm.NodeName)OSDrive.Vhd"
                        SwitchName      = "$($vm.UseSwitch)"
                        State           = "Running"
                        Path            = "$VMFolder\"
                        StartupMemory   = "$($vm.Memory)"
                        ProcessorCount  = "$($vm.CPUCount)"
                        RestartIfNeeded = $true
                        Generation      = 1
                    }
                }
                Else{
                    xVMHyperV "$($vm.NodeName)vm"
                    {
                        Ensure          = "Present"
                        Name            = "$($vm.NodeName)"
                        VhdPath         = "$VMFolder\$($vm.NodeName)\Virtual Hard Disks\$($vm.NodeName)OSDrive.Vhdx"
                        SwitchName      = "$($vm.UseSwitch)"
                        State           = "Running"
                        Path            = "$VMFolder\"
                        StartupMemory   = "$($vm.Memory)"
                        ProcessorCount  = "$($vm.CPUCount)"
                        RestartIfNeeded = $true
                        Generation      = 2
                    }
                }            
            }
        }

        node $AllNodes.Where{$_.Role -match "PrimaryDomainController"}.NodeName
        {
            xComputer SetName { 
              Name = $Node.NodeName 
            }

            xPendingReboot RenameComputerReboot 
            {  
                Name = ‘BeforeDCPrep’ 
            } 

            xIPAddress SetIP {
                IPAddress      = $Node.IPAddress
                InterfaceAlias = $Node.InterfaceAlias
                SubnetMask     = $Node.SubnetMask
                AddressFamily  = $Node.AddressFamily
            }

            xDNSServerAddress SetDNS {
                Address        = $Node.DNSAddress
                InterfaceAlias = $Node.InterfaceAlias
                AddressFamily  = $Node.AddressFamily
            }

            WindowsFeature ADDSInstall {
                Ensure = 'Present'
                Name   = 'AD-Domain-Services'
                IncludeAllSubFeature = $true
            }

            WindowsFeature RSATTools
            {            
                Ensure = 'Present'
                Name   = 'RSAT-AD-Tools'
                IncludeAllSubFeature = $true
                DependsOn = '[WindowsFeature]ADDSInstall'
            }

            xADDomain FirstDC {
                DomainName                    = $Node.DomainName
                DomainNetbiosName             = $Node.DomainName.Split('.')[0]
                DomainAdministratorCredential = $domainCred
                SafemodeAdministratorPassword = $safemodeCred
                DependsOn = '[xComputer]SetName', '[xIPAddress]SetIP', '[WindowsFeature]ADDSInstall'
            }

            xPendingReboot BeforeDHCPConfig 
            {  
                Name = ‘BeforeDHCPConfig’ 
            } 

            WindowsFeature DHCP { 
                Ensure               = 'Present'           
                Name                 = 'DHCP'
                IncludeAllSubFeature = $true                                                                                                                              
                DependsOn            = '[xIPAddress]SetIP'
            }

            #TODO: Set this dynamic:
            xDhcpServerScope Scope{
                Ensure        = 'Present'
                IPEndRange    = '192.168.0.250'
                IPStartRange  = '192.168.0.100'
                Name          = 'DEMOScope'
                SubnetMask    = '255.255.255.0'
                LeaseDuration = '00:08:00'
                State         = 'Active'
                AddressFamily = 'IPv4'
                DependsOn     = '[WindowsFeature]DHCP'
             }

            #TODO: Set this dynamic:
            xDhcpServerOption Option
            {
                Ensure             = 'Present'
                ScopeID            = '192.168.0.0'
                DnsDomain          = 'demo.local'
                DnsServerIPAddress = '192.168.0.21'
                AddressFamily      = 'IPv4'
            }
        }

        node $AllNodes.Where{$_.Role -match "Member"}.NodeName
        {
            xIPAddress SetIP {
                IPAddress      = $Node.IPAddress
                InterfaceAlias = $Node.InterfaceAlias
                SubnetMask     = $Node.SubnetMask
                AddressFamily  = $Node.AddressFamily
            }

            xDNSServerAddress SetDNS {
                Address        = $Node.DNSAddress
                InterfaceAlias = $Node.InterfaceAlias
                AddressFamily  = $Node.AddressFamily
            }

            xPendingReboot IpConfigReboot 
            {  
                Name = ‘AfterComputerRename’
            }

            xComputer JoinDoomain {
              Name       = $Node.NodeName
              DomainName = $Node.DomainName
              Credential = $domainCred
            }

            xPendingReboot DomainJoinReboot 
            {  
                Name = ‘AfterDominJoin’
            }
        }
    }

    #Build MOF Contracts:
    Contracts -ConfigurationData $ConfigurationDataFile -domainCred $DomainAdminCred -safemodeCred $SafeModeAdminCred -OutputPath "$Source\Contracts" | Out-Null

}