Function Start-ENVBuilder{

    [CmdletBinding()]
    Param (
            [Parameter(Position=0, Mandatory = $true)]
            [Alias('Path')]
            [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformation()]
            [hashtable] $ConfigurationDataFile
    )

    #Load Configuration from ConfigurationDataFile:
    [string]$Source        = $ConfigurationDataFile.AllNodes.ENVSource
    [string]$VMFolder      = $ConfigurationDataFile.AllNodes.ENVvmpath
    [string]$ISOLibrary    = $ConfigurationDataFile.AllNodes.ENVIsoPath
    [bool]$PreReqs         = $ConfigurationDataFile.AllNodes.ENVprereqs
    [string]$AdminPassword = $ConfigurationDataFile.AllNodes.ENVlocalpassword

    #TODO: Remove or change the behavior below:
    $Pass              = ConvertTo-SecureString $AdminPassword -AsPlainText -Force 
    $DomainAdminCred   = New-Object System.Management.Automation.PSCredential ("DEMO\Administrator", $Pass) #TODO: Change DomainName
    $SafeModeAdminCred = New-Object System.Management.Automation.PSCredential ("Administrator", $Pass)

    # MAIN:
    Write-Verbose "Starting ENV Builder..."

    #Check PreReqs:
    $fixPrereqs = Get-ENVprereqs -ConfigurationDataFile $ConfigurationDataFile
    If(-not $fixPrereqs) {Write-Verbose "Missing prereqs!" ; Return}

    #Build MOF contracts for DSC:
    Set-ENVlcmConfiguration -ConfigurationDataFile $ConfigurationDataFile
    Set-ENVconfiguration    -ConfigurationDataFile $ConfigurationDataFile
    $AllVMs = $ConfigurationDataFile.AllNodes.Where{$_.IsVM -eq $true}
    ForEach ($vm in $AllVMs){

        #TODO Verfify if folders exist...
        Write-Verbose "Creating DSC LCM Document for node: $($vm.NodeName)"
        New-Item -ItemType Directory -Path "$Source\Nodes\$($vm.NodeName)\DSC" -Force  | Out-Null
        Move-Item -Path "$Source\Contracts\$($vm.NodeName).mof" -Destination "$Source\Nodes\$($vm.NodeName)\DSC\localhost.mof"      -Force | Out-Null
        Copy-Item -Path "$Source\Contracts\localhost.meta.mof"  -Destination "$Source\Nodes\$($vm.NodeName)\DSC\localhost.meta.mof" -Force | Out-Null
    }

    Write-Verbose "Configuring LCM for localhost..."
    Set-DscLocalConfigurationManager -Path "$Source\Contracts"

    #Start up VM machines:
    Write-Verbose "Running DSC for localhost..."
    Start-DscConfiguration -Path "$Source\Contracts" -Wait -Force

    #TODO: Check to see if OS is up and running... workaround, wait 5 min, DoUntil with Write-Verbose...!
    $Timer = 0
    Do{
        Start-Sleep -Seconds 10
        $Timer = $Timer + 10
    
        Write-Verbose "Waiting for OS runtime to be complete ($Timer sec)..."
    }
    Until($Timer -eq 300)
    Write-Verbose "OS runtime probably up now, Timer = $Timer"

    #Import files to VMs:
    ForEach ($vm in $AllVMs){

        #TODO: Check to see if its configured

        #Activate Integration Service
        Write-Verbose "Activating VMIntegration Service on node: $($vm.NodeName)"
        Enable-VMIntegrationService -VMName $($vm.NodeName) -Name "Guest Service Interface" | Out-Null
        Start-Sleep -Seconds 5 #TODO, Check if its enables instead...
    
        #Import files to VM:
        Try{
            #Modules
            Get-ChildItem "$Source\Modules" -Recurse -File | 
                ForEach-Object {Copy-VMFile -Name $($vm.NodeName) -SourcePath $_.FullName -DestinationPath $_.FullName -CreateFullPath -FileSource Host -Force}

            #DSC Contracts
            Get-ChildItem "$Source\Nodes\$($vm.NodeName)" -Recurse -File | 
                ForEach-Object {Copy-VMFile -Name $($vm.NodeName) -SourcePath $_.FullName -DestinationPath $_.FullName -CreateFullPath -FileSource Host -Force}

            #TODO: Add More LabFiles files...

        }
        Catch{}
    
        #Run Configurations (Only if template is W2016 or NANO)...
        $VMName = $($vm.NodeName)

        If($($vm.UseTemplate -match "W2016") -or $($vm.UseTemplate -match "NANO")){
            
            Write-Verbose "Found Windows 2016 Machine: $($vm.NodeName) , using PowerShell Direct to invoke DSC!"
            Invoke-Command -VMName $($vm.NodeName) -ScriptBlock{
        
                #Import Modules:
                Try{
                    #TODO: Check for module folders to move...
                    Move-Item -Path "$using:Source\Modules\xNetworking"         -Destination 'C:\Program Files\WindowsPowerShell\Modules' -ErrorAction SilentlyContinue
                    Move-Item -Path "$using:Source\Modules\xComputerManagement" -Destination 'C:\Program Files\WindowsPowerShell\Modules' -ErrorAction SilentlyContinue
                    Move-Item -Path "$using:Source\Modules\xPendingReboot"      -Destination 'C:\Program Files\WindowsPowerShell\Modules' -ErrorAction SilentlyContinue
                    Move-Item -Path "$using:Source\Modules\xHyper-V"            -Destination 'C:\Program Files\WindowsPowerShell\Modules' -ErrorAction SilentlyContinue
                    Move-Item -Path "$using:Source\Modules\xActiveDirectory"    -Destination 'C:\Program Files\WindowsPowerShell\Modules' -ErrorAction SilentlyContinue
                    Move-Item -Path "$using:Source\Modules\xDhcpServer"         -Destination 'C:\Program Files\WindowsPowerShell\Modules' -ErrorAction SilentlyContinue
                }
                Catch{}
        
                #Start DSC
                Set-DscLocalConfigurationManager "$using:Source\Nodes\$using:VMName\DSC" #-Verbose
                Start-DscConfiguration "$using:Source\Nodes\$using:VMName\DSC" #-Wait -Verbose -Force

            } -Credential $SafeModeAdminCred #TODO: Hide output job.

            #TODO: Check if Domain is up - Workaround right now, wait for 10 min.
            If ($vm.Role -match "PrimaryDomainController"){
        
                $Timer = 0
                Do{
                    Start-Sleep -Seconds 10
                    $Timer = $Timer + 10
                    Write-Verbose "Waiting for Domain Controller to be complete ($Timer sec)..."
                }
                Until($Timer -eq 900)
                Write-Verbose "Domain Controller probably up now, Timer = $Timer"
            }
        }    
    }
    Write-Verbose "ENV Builder completed!"
}