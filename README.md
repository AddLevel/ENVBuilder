# ENVBuilder
A PowerShell Module that uses DSC for building tests

This module is an environment builder that you can use to build local testcases and demos with. We use it on AddLevel for simple DSC scenarios and testing our cMDT DSC module with.
Download the module by running the below command:

Find-Module ENVBuilder | Install-Module

In the installation folder there is an “Examples” directory that holds the different configurations that you could use for building a test environment. We will provide more cases later on but right now the two you can use are for Windows Server 2016 and Windows Server 2012.
Start the ENV builder by running:

Start-ENVBuilder -ConfigurationDataFile 'C:\Program Files\WindowsPowerShell\Modules\ENVBuilder\1.0.0.0\Examples\WindowsServer2016Summit\WindowsServer2016Summit.psd1' –Verbose

