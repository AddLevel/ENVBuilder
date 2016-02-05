@{
    AllNodes = 
    @(
        @{
            #Gloab Settings for ENV Builder:
            NodeName                    = "*"
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser        = $true
            ENVSource                   = "C:\cMDTtest"
            ENVisopath                  = "C:\ISO"
            ENVvmpath                   = "C:\cMDTtest\VMS"
            ENVlocalpassword            = "P@ssw0rd"
            ENVprereqs                  = $true
            ENVvhdxtemplates            = @(
                @{  
                    Template = "W2012R2"
                    VhdxFile = "W2012R2.vhdx"
                    ISOFile  = "10586.0.151029-1700.TH2_RELEASE_SERVER_OEMRET_X64FRE_EN-US.ISO"
                }
            )

        },

        @{
            NodeName       = "localhost"
            NodeOS         = "W10"
            Role           = "HyperV"
            SwitchName     = "DEMO"
            SwitchType     = "Internal"
        },


        @{
            NodeName       = "DEMO-DC"
            Role           = "PrimaryDomainController"
            InterfaceAlias = "Ethernet"
            IPAddress      = "192.168.0.21"
            SubnetMask     = 24
            AddressFamily  = "IPv4"
            DNSAddress     = "127.0.0.1"
            DomainName     = "demo.local"
            DomainNetBios  = "demo"
            IsVM           = $true
            UseTemplate    = "W2012"
            Memory         = 1GB
            CPUCount       = 2
            UseSwitch      = "DEMO"
        },


        @{
            NodeName       = "DEMO-MEM"
            Role           = "Member"
            InterfaceAlias = "Ethernet"
            IPAddress      = "192.168.0.22"
            SubnetMask     = 24
            AddressFamily  = "IPv4"
            DNSAddress     = "192.168.0.21"
            JoinDomain     = $true
            DomainName     = "demo.local"
            IsVM           = $true
            UseTemplate    = "W2012"
            Memory         = 2GB
            CPUCount       = 2
            UseSwitch      = "DEMO"
        }
    ); 
}