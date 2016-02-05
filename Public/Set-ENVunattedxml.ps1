Function Set-ENVunattendXML{

#Borrowed from: https://pwrshell.net/dsc-resource-create-an-unattend-xml-file/
[CmdletBinding()]
Param(
    [string]$SourcePath,
    [string]$ComputerName,
    [string]$Password     ="P@ssw0rd",
    [string]$TimeZone     ="W. Europe Standard Time",
    [string]$InputLocale  ="sv-SE",
    [string]$SystemLocale ="sv-SE",
    [string]$UserLocale   ="sv-SE"
)

Write-Verbose "  Runnign Set-ENVunattedXML"

[xml]$UnattendFile = @"
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="specialize">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <ComputerName>$ComputerName</ComputerName>
            <RegisteredOrganization>DEMO</RegisteredOrganization>
            <RegisteredOwner>DemoUser</RegisteredOwner>
            <TimeZone>$TimeZone</TimeZone>
        </component>
    </settings>
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">          
            <UserAccounts>
                <AdministratorPassword>
                    <Value>$Password</Value>
                    <PlainText>true</PlainText>
                </AdministratorPassword>
            </UserAccounts>
            <TimeZone>$TimeZone</TimeZone>
            <AutoLogon>
	            <Password>
	                <Value>$Password</Value>
	                <PlainText>true</PlainText>
	            </Password>
                <Username>administrator</Username>
                <LogonCount>2</LogonCount>
                <Enabled>true</Enabled>
            </AutoLogon>
            <RegisteredOrganization>DEMO</RegisteredOrganization>
            <RegisteredOwner>DemoUser</RegisteredOwner>
            <OOBE>
                <HideEULAPage>true</HideEULAPage>
                <SkipMachineOOBE>true</SkipMachineOOBE>
            </OOBE>
        </component>
        <component name="Microsoft-Windows-International-Core" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
          <InputLocale>$InputLocale</InputLocale>
          <SystemLocale>$SystemLocale</SystemLocale>
          <UILanguage>en-US</UILanguage>
          <UserLocale>$UserLocale</UserLocale>
        </component>
    </settings>
    <cpi:offlineImage cpi:source="" xmlns:cpi="urn:schemas-microsoft-com:cpi" />
</unattend>    
"@

$UnattendFile.Save("$SourcePath\unattend.xml")

}