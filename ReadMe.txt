#########################################
# Last Update: 17/12/2019		#
# Owner: Tony Reardon			#
# 			#
#					#
#					#
#########################################

Version: 0.1 02/12/2019	
#Warning
Support-DeployMenu -> AIGSmartMenu.ps1 typically contains scripts that will only list information from vCenter but please ensure you know what youre running before you do so

#How to install & Run PowerCLI on 64bit PowerShell

1. Open PowerShell
2. Run	  "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser"	This allows you to run RemoteSigned Scripts
3. Run    "Save-Module -Name VMware.PowerCLI -Path C:\Temp\"				Will Save Modules to your desktop
4. Run    "Install-Module -Name VMware.PowerCLI"					Installs PowerCLI
5. Run    "Import-Module VMware.PowerCLI -Verbose"					Imports PowerCLI Modules for use
6. Run    "Set-PowerCLIConfiguration -InvalidCertificateAction Ignore"			Ignores Invalid Certificate Warnings

#How to run Menu
1. Right click AIGSmartMenu.ps1 and select "Run with Powershell" 
2. Follow Instructions 

FYI: Requested file path is used in exporting CSVs of selected command output

############################################################################################################################################

Version: 0.2 17/12/2019
Menu Option 11 - Now includes option to pull currently provisioned CPU/Mem resources of a cluster including Phy/Virt ratios 
