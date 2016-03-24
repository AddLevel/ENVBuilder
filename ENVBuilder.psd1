@{

# Script module or binary module file associated with this manifest.
RootModule =  'ENVBuilder.psm1'

# Version number of this module.
ModuleVersion = '1.0.0.0'

# ID used to uniquely identify this module
GUID = '270654d1-155b-4fcd-bbea-d381816f9ebd'

# Author of this module
Author = 'Richard Ulfvin'

# Company or vendor of this module
CompanyName = 'AddLevel'

# Copyright statement for this module
Copyright = '(c) 2016 . All rights reserved.'

# Description of the functionality provided by this module
Description = 'Build test enviroments based on DSC'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.0'

FunctionsToExport = @(  'Start-ENVBuilder',
                        'Get-ENVprereqs',
                        'Set-ENVunattedXML',
                        'Set-ENVvhdx',
                        'Set-ENVnanovhdx',
                        'Set-ENVlcmconfiguration',
                        'Set-ENVconfiguration'
                        )
}
