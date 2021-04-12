#This PowerShell script has been created by mardiieIT
param([switch]$Elevated)
#variables
$get_policy = Get-ExecutionPolicy
$get_value = (Get-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\Filesystem').GetValue('LongPathsEnabled')
$quit = "Script ran without making changes.`n"
#functions:
function Test-Elevated {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}
#start of script:
Write-Output "" 
Write-Output "This script will guide you through the steps to activate the MAX_PATH function in Windows 10.`n`nPlease note Microsoft sees this as an expiremental feature and developers have to first update their application to support this function.`n"
#language switch???
if ( (Test-Elevated) -eq $false ) 
{
	if ( $elevated )
	{
		Write-Output "Did not get permission to run as Administrator`n"
	}
	else
	{
		#elevate to administrator
		$adminq = Read-Host "The script needs to be run as Administrator and the script ExecutionPolicy has to be bypassed. Continue? y/n"
		Write-Output ""
		if ( $adminq -match "y" )
		{
			Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -windowstyle maximized -noexit -executionpolicy bypass -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
		}
	}
	exit
}
if ( (Test-Elevated) -eq $true )
{
	Write-Output "Executing as Administrator.`n"
}
if ( $get_policy -eq 'Bypass' )
{
	Write-Output "The ExecutionPolicy has been bypassed.`n"
}
#check windows build
Write-Output "The Windows 10 build version need to be equal or higher then 14393.`n"
$windows_version = [System.Environment]::OSVersion.Version.Build
if ( $windows_version -ge '14393') 
{ 
	Write-Output "Windows 10 build version $windows_version (14393 required). Pass!`n" 
}
else 
{ 
	Write-Output "Your Windows 10 build version is out of date. Please perform Windows Update`nWindows 10 build version $windows_version (14393 required). Fail!`n"
	Write-Output $quit		
}
#create/modify key if needed
If ( $get_value -eq 1 )
{ 
	Write-Output "LongPathsEnabled value is already set to true.`n" 			
} 
#question continue by changing key value? 
elseif ( $get_value -eq 0 )
{ 
	$changeregq = Read-Host "The required key (LongPathsEnabled) has been found but needs to be set to true. Continue? y/n"
	Write-Output ""
	if ( $changeregq -match "y" )
	{
		(Get-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\').OpenSubKey('Filesystem', $true).SetValue('LongPathsEnabled', 1)
		Write-Output "LongPathsEnabled key has been set to true.`n"
		
	}
	else
	{
		Write-Output $quit				
	}
}
#question continue with creation of key?
else 
{ 
	$changeregq = Read-Host "The required key (LongPathsEnabled) has NOT been found and needs to be created and set to true. Continue? y/n"
	Write-Output ""
	if ( $changeregq -match "y" )
	{
		(Get-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\').OpenSubKey('Filesystem', $true).SetValue('LongPathsEnabled', 1)
		Write-Output "LongPathsEnabled key (DWORD) has been created and set to true`n" 
		
	}
	else
	{
		Write-Output $quit					
	}
}
$get_exit_value = (Get-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\Filesystem').GetValue('LongPathsEnabled')
If ( $get_exit_value -eq 0 )
{ 
	Write-Output "Something went awry.`n" 
	Write-Output $quit			
} 
else 
{
	Write-Output "Confirmed that registry key is set to true.`n`nRaw value: $get_exit_value`n"
}

Write-Output "Done.`n"