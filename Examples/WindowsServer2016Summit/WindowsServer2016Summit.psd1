@{
    AllNodes = 
    @(
        @{
            #Gloab Settings for ENV Builder:
            NodeName                    = "*"
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser        = $true
            DomainName                  = "demo.local"
            DomainNetBios               = "demo"
            ENVSource                   = "C:\LabFiles"
            ENVisopath                  = "C:\LabFiles\ISO"
            ENVvmpath                   = "C:\LabFiles\VMS"
            ENVlocalpassword            = "P@ssw0rd"
            ENVprereqs                  = $true
            ENVvhdxtemplates            = @(
                @{  
                    Template = "W2016"
                    VhdxFile = "W2016.vhdx"
                    ISOFile  = "10586.0.151029-1700.TH2_RELEASE_SERVER_OEMRET_X64FRE_EN-US.ISO"
                },
                @{  
                    Template = "NANO"
                    VhdxFile = "NANO.vhdx"
                    ISOFile  = "10586.0.151029-1700.TH2_RELEASE_SERVER_OEMRET_X64FRE_EN-US.ISO"
                }
            )

        },

        @{
            NodeName       = "localhost"
            NodeOS         = "Windows10"
            Role           = "HyperV"
            SwitchName     = "DEMO"
            SwitchType     = "Internal"
        },


        @{
            NodeName       = "W16-DC1"
            Role           = "PrimaryDC"
            InterfaceAlias = "Ethernet"
            IPAddress      = "192.168.0.21"
            SubnetMask     = 24
            AddressFamily  = "IPv4"
            DNSAddress     = "127.0.0.1"
            DomainName     = "demo.local"
            DomainNetBios  = "demo"
            IsVM           = $true
            UseTemplate    = "W2016"
            Memory         = 2GB
            CPUCount       = 2
            UseSwitch      = "DEMO"
            DHCPOptions    = @(
                @{
                    Name               = 'DEMOScope'
                    ScopeID            = '192.168.0.0'
                    DnsDomain          = 'demo.local'
                    DnsServerIPAddress = '192.168.0.21'
                    AddressFamily      = 'IPv4'
                    IPStartRange       = '192.168.0.100'
                    IPEndRange         = '192.168.0.250'
                    SubnetMask         = '255.255.255.0'
                    LeaseDuration      = '00:08:00'
                    State              = 'Active'
                }
            )
        },


        @{
            NodeName       = "W16-NA1"
            Role           = "Member"
            InterfaceAlias = "Ethernet"
            IPAddress      = "192.168.0.22"
            SubnetMask     = 24
            AddressFamily  = "IPv4"
            DNSAddress     = "192.168.0.21"
            JoinDomain     = $true
            DomainName     = "demo.local"
            IsVM           = $true
            UseTemplate    = "W2016"
            Memory         = 1GB
            CPUCount       = 1
            UseSwitch      = "DEMO"
        }
    ); 
}