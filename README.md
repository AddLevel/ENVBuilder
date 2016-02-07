# ENVBuilder
A PowerShell Module that uses DSC for building tests

This module is an environment builder that you can use to build local testcases and demos with. We use it on AddLevel for simple DSC scenarios and testing our cMDT DSC module with.

### Version
1.0.0.0

### Installation
Download the module by running the below command:

```sh
Find-Module ENVBuilder | Install-Module
```

In the installation folder there is an “Examples” directory that holds the different configurations that you could use for building a test environment. We will provide more cases later on but right now the two you can use are for Windows Server 2016 and Windows Server 2012.
Start the ENV builder by running:

```sh
Start-ENVBuilder -ConfigurationDataFile 'C:\Program Files\WindowsPowerShell\Modules\ENVBuilder\1.0.0.0\Examples\WindowsServer2016Summit\WindowsServer2016Summit.psd1' –Verbose
```
When you run it the first time, a lot of pre requisites are missing:
![alt text](https://github.com/AddLevel/ENVBuilder/blob/master/Screenshots/1PrereqsMissing.png "First Run Prereqs are missing")

You first need the ISO file to build the template VHDX file for Windows Server 2016, you can download it from the URL:
https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-technical-preview

If you try to run it again after you created the ISO library with the template file, you also need to download the script **Convert-WindowsImage.ps1** as displayed in the warning:
![alt text](https://github.com/AddLevel/ENVBuilder/blob/master/Screenshots/2PrereqsMissing.png "First Run Prereqs are missing")

This could be found here:
https://gallery.technet.microsoft.com/scriptcenter/Convert-WindowsImageps1-0fe23a8f/file/59237/7/Convert-WindowsImage.ps1

Place the file in the source location, default this is **C:\LabFiles\**
And import it by running **Import-Module C:\LabFiles\Convert-WindowsImage.ps1**
Then run the command below to build a vhdx template:
```sh
Convert-WindowsImage -UnattendPath C:\LabFiles\unattend.xml -VHDPath C:\LabFiles\VMS\Templates\W2016.vhdx -VHDPartitionStyle GPT -VHDFormat VHDX -Edition ServerDataCenter -SizeBytes 60GB -SourcePath C:\LabFiles\ISO\10586.0.151029-1700.TH2_RELEASE_SERVER_OEMRET_X64FRE_EN-US.ISO
```
Also, if you need to build a image for Nano server, you might be warned about some more prereqfiles that you need to download.
When thay are in place under the **Nano** folder, you can build the template disk by runnig the command:
```sh
New-NanoServerVHD.ps1 -ServerISO C:\LabFiles\ISO\10586.0.151029-1700.TH2_RELEASE_SERVER_OEMRET_X64FRE_EN-US.ISO -Packages 'Compute','Guest','Containers','ReverseForwarders','DSC' -VHDFormat VHDX -UnattendedContent C:\LabFiles\unattend.xml -DestVHD C:\LabFiles\Nano.vhdx -AdministratorPassword P@ssw0rd
```

Now the ENV Builder should work and it will build a working domain controller and member servers for you to test with.

License
----

MIT
