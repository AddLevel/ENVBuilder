Function Set-ENVNanoVHDX{

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformation()]
        [hashtable] $ConfigurationDataFile,
        $VHDPath,
        $ISO
    )

    #Load Configuration from ConfigurationDataFile:
    [string]$Source     = $ConfigurationDataFile.AllNodes.ENVSource
    [string]$Password   = $ConfigurationDataFile.AllNodes.ENVlocalpassword

    Write-Verbose "  Runnign Set-ENVNanoVHDX"

    $Parameters = @{
        ServerISO             = $ISO
        DestVHD               = $VHDPath
        ComputerName          = 'NANO'
        AdministratorPassword = $Password
        Packages              = 'DSC','Guest'
        VHDFormat             = 'VHDX'
    }
    
    . $Source\Tools\Nano\New-NanoServerVHD.ps1 @Parameters
}



<#
 .\New-NanoServerVHD.ps1 `
            -ServerISO 'C:\LabFiles\ISO\10586.0.151029-1700.TH2_RELEASE_SERVER_OEMRET_X64FRE_EN-US.ISO' `
            -DestVHD C:\LabFiles\VMS\Templates\NANO.vhdx `
            -ComputerName NANO `
            -AdministratorPassword 'P@ssw0rd' `
            -Packages 'Containers','DSC','Guest' `
            -VHDFormat VHDX


C:\LabFiles\Tools\Nano>New-NanoServerVHD.ps1 -ServerISO 'C:\LabFiles\ISO\10586.0.151029-1700.TH2_RELEASE_SERVER_OEMRET_X64FRE_EN-US.ISO' -DestVHD C:\LabFiles\VMS\Templates\NANO.vhdx -ComputerName NANO -AdministratorPassword 'P@ssw0rd' -Packages 'Containers','DSC','Guest' -VHDFormat VHDX
#>