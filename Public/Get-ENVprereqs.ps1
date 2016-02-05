Function Get-ENVprereqs{

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformation()]
        [hashtable] $ConfigurationDataFile
    )

    #Load Configuration from ConfigurationDataFile:
    [bool]$IsReady      = $false
    [string]$Source     = $ConfigurationDataFile.AllNodes.ENVSource
    [string]$ISOLibrary = $ConfigurationDataFile.AllNodes.ENVisopath
    [string]$VMFolder   = $ConfigurationDataFile.AllNodes.ENVvmpath

    $Modules    = @(
    @{
       Name    = "xComputerManagement"
       Version = "1.3.0"
    },
    
    @{
       Name    = "xPendingReboot"
       Version = "0.1.0.2"
    },

    @{
       Name    = "xActiveDirectory"
       Version =  "2.8.0.0"
    },

    @{
       Name    = "xHyper-V"
       Version =  "3.2.0.0"
    },

    @{
       Name    = "xNetworking"
       Version =  "2.5.0.0"
    },

    @{
       Name    = "xDhcpServer"
       Version =  "1.2"
    }
)

    Write-Verbose "  Running Get-ENVPrereqs"

    #Check Modules:
    ForEach ($Module in $Modules)
    {        
        If (-not (Test-Path "$Source\Modules\$($Module.Name)"))
        {   
            Write-Verbose "  Downloading module: $($Module.Name)"
            Find-DscResource -moduleName $Module.Name -RequiredVersion $Module.Version | Install-Module -Force
            Copy-Item -Path "$env:ProgramFiles\WindowsPowerShell\Modules\$($Module.Name)" -Recurse -Destination "$Source\Modules\$($Module.Name)" -Force        
        }
    }

    #Check folders
    If(-not (Test-Path "$VMFolder\Templates")) {New-Item -ItemType Directory -Path "$VMFolder\Templates" | Out-Null}    
    If(-not (Test-Path "$Source\Contracts"))   {New-Item -ItemType Directory -Path "$Source\Contracts"   | Out-Null}
    If(-not (Test-Path "$Source\Tools"))       {New-Item -ItemType Directory -Path "$Source\Tools"       | Out-Null}

    #Check for Unatteded XMl
    If(-not (Test-Path -Path "$Source\unattend.xml")){Set-ENVunattendXML -ComputerName "NONAME" -Password $AdminPassword -SourcePath $Source}

    #Check for all ISOs:
    $ISOs = @($ConfigurationDataFile.AllNodes.ENVvhdxtemplates.ISOFile)
    ForEach ($i in $ISOs)
    {
        If (-not (Test-Path -Path "$ISOLibrary\$i")){
            Write-Warning "  You need to download $ISOLibrary\$i"
            Return $IsReady
        }
    }   

    #Check for all Templates
    $Templates = @($ConfigurationDataFile.AllNodes.ENVvhdxtemplates)
    ForEach($t in $Templates)
    {
        If (-not (Test-Path -Path "$VMFolder\Templates\$($t.VhdxFile)")){
            Write-Warning "  You need to build a template at $VMFolder\Templates\$($t.VhdxFile)"

            #Test for Convert-Wim Return $IsReady
            If(-not (Test-Path "$Source\Tools\Convert-WindowsImage.ps1")){
                Write-Warning "  You need to download Convert-WindowsImage.ps1 Script!"
                Write-Warning "  From: https://gallery.technet.microsoft.com/scriptcenter/Convert-WindowsImageps1-0fe23a8f/file/59237/7/Convert-WindowsImage.ps1"
                Write-Warning "  To: $Source\Tools"
                Return $IsReady
            }

            #Test for NANO builder...
            If($t.Template -match "NANO"){
                If(-not (Test-Path "$Source\Tools\Nano\New-NanoServerVHD.ps1")){
                    Write-Warning "  You need to download New-NanoServerVHD.ps1 Script!"
                    Write-Warning "  From: https://gallery.technet.microsoft.com/scriptcenter/Create-a-New-Nano-Server-61f674f1/file/145315/1/New-NanoServerVHD.ps1"
                    Write-Warning "  To: $Source\Tools\Nano folder"
                }

                If(-not (Test-Path "$Source\Tools\Nano\Convert-WindowsImage.ps1")){
                    Write-Warning "  You need to download Convert-WindowsImage.ps1 Script!"
                    Write-Warning "  From: https://raw.githubusercontent.com/PlagueHO/Powershell/master/New-NanoServerVHD/Convert-WindowsImage.ps1"
                    Write-Warning "  To: $Source\Tools\Nano folder"
                }

                #TODO:Set-ENVNanoVHDX -VHDPath "$VMFolder\Templates\$($t.VhdxFile)" -ISO "$ISOLibrary\$($t.ISOFile)" -ConfigurationDataFile $ConfigurationDataFile
                Return $IsReady
            }
            Else{
                #TODO:Set-ENVvhdx     -VHDPath "$VMFolder\Templates\$($t.VhdxFile)" -ISO "$ISOLibrary\$($t.ISOFile)" -ConfigurationDataFile $ConfigurationDataFile
                Return $IsReady
            }       
        }
        $IsReady = $true
    }
    
    Return $IsReady

}