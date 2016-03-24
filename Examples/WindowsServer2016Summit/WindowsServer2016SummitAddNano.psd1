@{
    AllNodes = 
    @(
        @{
            #Gloab Settings for ENV Builder:
            NodeName                    = "*"
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser        = $true
            ENVSource                   = "C:\LabFiles"
            ENVisopath                  = "C:\LabFiles\ISO"
            ENVvmpath                   = "C:\LabFiles\VMS"
            ENVlocalpassword            = "P@ssw0rd"
            ENVprereqs                  = $true
            ENVvhdxtemplates            = @(
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
            NodeName       = "W16-NA1"
            Role           = "Nano"
            InterfaceAlias = "Ethernet"
            IPAddress      = "192.168.0.30"
            SubnetMask     = 24
            AddressFamily  = "IPv4"
            DNSAddress     = "192.168.0.21"
            IsVM           = $true
            UseTemplate    = "NANO"
            Memory         = 1GB
            CPUCount       = 1
            UseSwitch      = "DEMO"
        }

        @{
            NodeName       = "W16-NA2"
            Role           = "Nano"
            InterfaceAlias = "Ethernet"
            IPAddress      = "192.168.0.31"
            SubnetMask     = 24
            AddressFamily  = "IPv4"
            DNSAddress     = "192.168.0.21"
            IsVM           = $true
            UseTemplate    = "NANO"
            Memory         = 1GB
            CPUCount       = 1
            UseSwitch      = "DEMO"
        }
    ); 
}