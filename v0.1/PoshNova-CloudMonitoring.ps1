<############################################################################################

                           ___          _         __                
                          / _ \___  ___| |__   /\ \ \_____   ____ _ 
                         / /_)/ _ \/ __| '_ \ /  \/ / _ \ \ / / _` |
                        / ___/ (_) \__ \ | | / /\  / (_) \ V / (_| |
                        \/    \___/|___/_| |_\_\ \/ \___/ \_/ \__,_|
                                      Monitoring as a Service (Maas)
                                           Rackspace CloudMonitoring

Authors
-----------
    Nielsen Pierce (nielsen.pierce@rackspace.co.uk)
    Alexei Andreyev (alexei.andreyev@rackspace.co.uk)
    
Description
-----------
PowerShell v3 module for interaction with NextGen Rackspace Cloud API (PoshNova) 

CloudMonitoring API reference
---------------------------
http://docs.rackspace.com/auth/api/v2.0/auth-client-devguide/content/Overview-d1e65.html

Core quick reference
http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/maas-core-service-calls.html

Agent quick reference
http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/maas-core-agents-service-calls.html

############################################################################################>

<#
List of cmdlets needed
-----------------------------
    Get Overview
    Get Limits
    Get Account
    Update Account
    List Audits
    List Metrics

    List Monitoring Zone
    Get Monitoring Zone Details
    Perform Traceroute From Zone

    Create Agent Token
    Get Agent Details
    Get Details For Agent Token
    Update Agent Token
    Delete Agent Token
    List Agent Tokens
    List Agents
    List Agent Check Type Targets
    List Agent Connections
    Get Agent Connection Details

    Create Entity
    Get Details Of Entity
    List Entities
    Update Entity
    Delete Entity
    Get System Information
    Get Logged In User Information
    Get Processes Information
    Get Processor Information
    Get Memory Information
    Get Disk Information
    Get Filesystem Information
    Get Network Interface Information

    List Check Types
    Get Check Type Details
    Create Check
    List Checks
    Get Check Details
    Update Check
    Test Check
    Test Check With Debug
    Test Existing Check
    Fetch Data Points
    Delete Check

    List Alarm Examples
    Get Details Of Alarm Example
    Evaluate Alarm Example
    Discover Alarm Notification History
    List Alarm Notification History
    Get Alarm Changelogs
    Get Entity Alarm Changelogs
    Get Alarm Notification History Details

    List Notification Types
    Create Notification
    List Notifications
    Get Details About Notification
    Get Details For Notification Type
    Update Notifications
    Test Existing Notification
    Test Notification
    Delete Notification
#>

<#
    Get Overview
    Get Limits
    Get Account
    Update Account
    List Audits
    List Metrics
#>

# Return the overview for the account (All entities with check and alarms)
function Get-CloudMonOverview {
    Param(
        [Parameter(Position=0, Mandatory=$True)][string] $Account = $(throw "Please specify required Cloud Account with -Account parameter"),
        [Parameter(Position=1, Mandatory=$False)][string]$RegionOverride
    )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

    Get-AuthToken($Account)
    $URI = (Get-CloudURI("monitoring")) + "/views/overview"

    (Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -ErrorAction Stop)

 <#
 .SYNOPSIS
 The Get-VirtualInterface cmdlet will get a list of virtual network interfaces on a server and provide additional relevant cloud network details for the server in question.

 .DESCRIPTION
 See synopsis.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file. 
 Please note that this switch is not supported for UK Cloud accounts

 .EXAMPLE
 PS C:\Users\Administrator> Get-VirtualInterfaces -ServerID e1dae019-c44b-4e3d-8418-e8b934a3dd8f -account prod
 This example shows how to list current virtual cloud network adapters for as server with an ID of e1dae019-c44b-4e3d-8418-e8b934a3dd8f from the account prod.

 .LINK
 http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/service-account.html
#>
}

$account = "cloud"