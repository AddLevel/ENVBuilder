Function Set-ENVlcmConfiguration{
    
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformation()]
        [hashtable] $ConfigurationDataFile
    )

    #Load Configuration from ConfigurationDataFile:
    [string]$Source        = $ConfigurationDataFile.AllNodes.ENVSource

    Write-Verbose "  Running Set-ENVlcmConfiguration"

    [DSCLocalConfigurationManager()]
    Configuration LCM
    {
        Node 'localhost'
        {
            Settings
            {
                AllowModuleOverwrite = $True
                ConfigurationMode    = 'ApplyAndMonitor'
                RefreshMode          = 'Push'
                Debugmode            = 'All'
                RebootNodeIfNeeded   = $True
            }
        }
    }
    LCM -OutputPath "$Source\Contracts" | Out-Null

}