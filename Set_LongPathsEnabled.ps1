#This PowerShell script has been created by mardiieIT
param([switch]$Elevated)
#variables
$get_policy = Get-ExecutionPolicy
$get_value = (Get-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\Filesystem').GetValue('LongPathsEnabled')
$quit = "Script cancelled without making changes.`n"
#functions:
function Test-Elevated {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}
#start of script:
Write-Output "This script will guide you through the steps to activate the MAX_PATH function in Windows 10.`n`nPlease note Microsoft sees this as an expiremental feature and developers have to first update their app to support this function.`n"
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
		$adminq = Read-Host "The script needs to be run as Administrator. Continue? y/n"
		Write-Output ""
		if ( $adminq -match "y" )
		{
			Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
		}
	}
	exit
}
Write-Output "Got permission to run as Administrator`n"
#set executing policy
if ( $get_policy -ne 'Unrestricted' )
{
	$adminq = Read-Host "The script needs to change the current execution policy from $get_policy to Unrestricted. Continue? y/n"
	Write-Output ""
	if ( $adminq -match "y" )
	{
		Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force
		Write-Output "Executing policy has been changed to unrestricted for the duration of the script.`n"
	}
	else
	{
		Write-Output "Did not get permission to change the execution policy.`n"
		Write-Output $quit
		exit
	}
}
#check windows build
Write-Output "The Windows 10 build version need to be equal or higher then 14393.`n"
$versionq = Read-Host "Would you like to continue by checking your Windows 10 build? y/n"
Write-Output ""
if ( $versionq -match "y" )
{
	Write-Output "Checking your Windows 10 build version...`n" 
	$windows_version = [System.Environment]::OSVersion.Version.Build
	if ( $windows_version -ge '14393') 
	{ 
		Write-Output "Your Windows 10 build version is $windows_version.`n" 
	}
	else 
	{ 
		Write-Output "Your Windows 10 build version is out of date and needs to be updated before you can use this feature.`nCurrent build version is $windows_version.`n"
		Write-Output $quit		
	}
	#create/modify key if needed
	$checkregq = Read-Host "Would you like to continue by checking if the required registry key already exists? y/n"
	Write-Output ""
	if ( $checkregq -match "y" ) 
	{
		If ( $get_value -eq 1 )
		{ 
			Write-Output "LongPathsEnabled value is already set to true.`n" 
			Write-Output $quit			
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
	}
}
else {
	Write-Output $quit	
}

Write-Output "Executing policy is being reverted back to previous setting $get_policy`n"
Set-ExecutionPolicy -ExecutionPolicy $get_policy -Force
Write-Output "Done."