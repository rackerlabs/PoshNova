# PoshNova

Current version `0.1`

Authors:  
Nielsen Pierce (nielsen.pierce@rackspace.co.uk)  
Alexei Andreyev (alexei.andreyev@rackspace.co.uk)  

## Description
PoshNova is a Microsoft PowerShell v3 script module intended for using directly with [Rackspace Public Cloud](http://www.rackspace.com/cloud/) API, which is built on OpenStack.

The primary intention of this project is to provide an easy-to-use tool to manage and automate environments hosted on Rackspace Public Cloud for Windows system administrators, DevOps engineers and developers alike. 

**The first version of this tool is in very early stages of development and cmndlet names and syntax is likely to change as the tools evolves, so please be aware of this when integrating it into your automation efforts.**

###History
This effort is a rewrite of Mitch Robin's original PowerClient work, which was originally published on [developer.rackspace.com](http://developer.rackspace.com/blog/powerclient-rackspace-cloud-api-powershell-client.html)

## Installing PoshNova
PoshNova is installed just like any other PowerShell module either in the system-wide module directory or user's home profile.

### Preparation
 - Ensure that Windows [Management Framework 3.0](http://www.microsoft.com/en-gb/download/details.aspx?id=34595) is installed on your machine, which includes PowerShell 3.0
 - Powershell Execution Policy must be set to RemoteSigned or Unrestricted (The module is unsigned at this time).
  - Documents folder on local storage: <pre>Set-ExecutionPolicy RemoteSigned</pre>
  - Documents folder on networked storage: <pre>Set-ExecutionPolicy Unrestricted</pre>
  - Note: The above policy settings are quite permissive, so feel free to modify these to fit in your environment. See  `help about_Execution_Policies` for full details on this.

### Install process
1.	Install all of the scripts in the module to `USERPROFILE\Documents\WindowsPowerShell\Modules\PoshNova\`. 
	If `USERPROFILE\Documents\WindowsPowerShell` does not exist, execute the following command in a Powershell console: <pre>New-item –type file –force $profile</pre>

2. 	Update CloudAccounts.csv file with your Cloud credentials:  
	* *CloudName* - User-defined name for the account for easy identification (used as input for -Account parameter) 
	* *CloudUsername* - Your Rackspace Cloud username
	* *CloudAPIKey* - Cloud API key
	* *CloudDDI* - Cloud account number
	* *Region* - Default region for this account, example: LON, DFW, ORD, SYD or HKG (At this time, LON region is the only one that cannot be overridden at this time)

	Example of **CloudAccounts.csv** format (included with the module):

	<pre>
	AccountName,CloudUsername,CloudAPIKey,CloudDDI,Region
	dummy1,clouduser,a3s45df6g78h9jk098h7g6f5d4s4d5f5,12345678,LON
	dummy2,dummyuser,a3s45df6g78h9jk098h7g6f5d4s4d5f6,87654321,dfw
	</pre>

3.	Either open a new PowerShell session and enter one of the PoshNova cmdlets to load the module dynamically or type the following to load PoshNova module in an existing session to start managing your Rackspace cloud environment:
	<pre>Import-Module PoshNova</pre>

## Getting Help
We aim to include help content for each cmdlet in PoshNova, so you should be able to type the following into a PS session (after the module is imported of course) and get details on how to use that specific cmdlet: <pre>Get-Help PoshNova-cmdletName</pre>

If you find incomplete or inaccurate information, please raise this with the team and we will correct it.

## Supported Cloud Services
Initial release has been tested to work with the following services, using the detailed cmdlets (use the Get-Help cmdlet_name to see more detailed usage information):  

- CloudIdentity  
	- Get-CloudIdentityUsers
	- Get-CloudIdentityRoles
	- Get-CloudIdentityUser
	- Get-CloudIdentityUserRoles
	- New-CloudIdentityUser
	- Remove-CloudIdentityUser
	- Edit-CloudIdentityUser
	- Add-CloudIdentityRoleForUser
	- Remove-CloudIdentityRoleForUser
- CloudServers  
	- Get-CloudLimits
	- Get-CloudServerImages
	- Get-CloudServerFlavors
	- Add-CloudServer
	- Get-CloudServers
	- Get-CloudServerDetails
	- Add-CloudServerImage
	- Remove-CloudServerImage
	- Get-CloudServerBlockVols
	- Update-CloudServer
	- Restart-CloudServer
	- Remove-CloudServer
	- Set-CloudServerRescueMode
- CloudNetworks  
	- Get-CloudNetworks
	- Add-CloudNetwork
	- Remove-CloudNetwork
	- Connect-VirtualInterface
	- Disconnect-VirtualInterface
	- Get-VirtualInterfaces
- CloudBlock Storage
	- Get-CloudBlockStorageTypes
	- Get-CloudBlockStorageVolList
	- Get-CloudBlockStorageVol
	- Add-CloudBlockStorageVol
	- Remove-CloudBlockStorageVol
	- Get-CloudBlockStorageSnapList
	- Get-CloudBlockStorageSnap
	- Add-CloudBlockStorageSnap
	- Remove-CloudBlockStorageSnap
	- Mount-CloudBlockStorageVol
	- Dismount-CloudBlockStorageVol
- Cloud LoadBalancers
	- Add-CloudLoadBalancer
	- Add-CloudLoadBalancerACLItem
	- Add-CloudLoadBalancerConnectionLogging
	- Add-CloudLoadBalancerConnectionThrottling
	- Add-CloudLoadBalancerContentCaching
	- Add-CloudLoadBalancerHealthMonitor
	- Add-CloudLoadBalancerNode
	- Add-CloudLoadBalancerSessionPersistence
	- Add-CloudLoadBalancerSSLTermination
	- Get-CloudLoadBalancerACLs
	- Get-CloudLoadBalancerAlgorithms
	- Get-CloudLoadBalancerDetails
	- Get-CloudLoadBalancerHealthMonitor
	- Get-CloudLoadBalancerNodeEvents
	- Get-CloudLoadBalancerNodeList
	- Get-CloudLoadBalancerProtocols
	- Get-CloudLoadBalancers
	- Get-CloudLoadBalancerSSLTermination
	- Remove-CloudLoadBalancer
	- Remove-CloudLoadBalancerACL
	- Remove-CloudLoadBalancerACLItem
	- Remove-CloudLoadBalancerConnectionLogging
	- Remove-CloudLoadBalancerConnectionThrottling
	- Remove-CloudLoadBalancerContentCaching
	- Remove-CloudLoadBalancerHealthMonitor
	- Remove-CloudLoadBalancerNode
	- Remove-CloudLoadBalancerSessionPersistence
	- Remove-CloudLoadBalancerSSLTermination
	- Update-CloudLoadBalancer
	- Update-CloudLoadBalancerConnectionThrottling
	- Update-CloudLoadBalancerNode
	- Update-CloudLoadBalancerSessionPersistence
	- Update-CloudLoadBalancerSSLTermination

The tools is being constantly expanded to work with more Rackspace Public Cloud services, so do check back frequently.

## Issues and getting help
If you have any problems with the tool or would like to improve things, feel free to contact the authors or submit your changes for us to review. 
