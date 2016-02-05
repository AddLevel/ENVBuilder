Function Set-ENVvhdx{

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformation()]
        [hashtable] $ConfigurationDataFile,
        $VHDPath,
        $ISO
    )

    #Load Configuration from ConfigurationDataFile:
    [string]$Source = $ConfigurationDataFile.AllNodes.ENVSource

    Write-Verbose "  Runnign Set-ENVvhdx"

    #TODO: Get WIM To VHDX Script and Unblock it:
    #https://gallery.technet.microsoft.com/scriptcenter/Convert-WindowsImageps1-0fe23a8f/file/59237/7/Convert-WindowsImage.ps1

    # Load (aka "dot-source) the Function
    Write-Verbose "  Importing Convert-WindowsImage.ps1"
    . $Source\Tools\Convert-WindowsImage.ps1   

    Write-Verbose "    Building $VHDPath"
    Write-Verbose "    With ISO $ISO"
    Write-Verbose "    Using $Source\unattend.xml"

    # Prepare all the variables in advance (optional)
    $VHDXPresent = Test-Path -Path $VHDPath

    If ($VHDXPresent -eq $false)
    {
        $Parameters = @{  
            SourcePath          = $ISO
            VHDPath             = $VHDPath
            VHDFormat           = "VHDX"
            VHDPartitionStyle   = "GPT"
            SizeBytes           = 60GB
            RemoteDesktopEnable = $True  
            Passthru            = $True
            UnattendPath        = "$Source\unattend.xml"
            Edition    = @(  
                "ServerDataCenter" 
            )
        }  
        # Produce the images 
        Convert-WindowsImage @Parameters
    }
}