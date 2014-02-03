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
http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/overview.html

Core quick reference
http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/maas-core-service-calls.html

Agent quick reference
http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/maas-core-agents-service-calls.html

############################################################################################>

<#
List of cmdlets needed
-----------------------------
    Get Overview - Get-CloudMonOverview (Basic object being returned)
    Get Limits - Get-CloudMonOverview (Basic object being returned)
    Get Account - Get-CloudMonOverview (Basic object being returned)
#   Update Account - NOT IMPLEMENTED
    List Audits - Get-CloudMonOverview (Basic object being returned)

#   List Metrics

    List Monitoring Zone - Show-CloudMonZone -Account prod
    Get Monitoring Zone Details - Show-CloudMonZone -Account prod -ZoneID mzsyd
    Perform Traceroute From Zone - Request-CloudMonZoneTracert -Account prod -ZoneID mzsyd -Target 0.0.0.0

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



function Get-CloudMonDetail {
    Param(
        [Parameter(Position=0, Mandatory=$True)][string] $Account = $(throw "-Account is required."),
        [Parameter(Position=1, Mandatory=$False)][ValidateSet("Overview","Limits","Audits","Account")][string]$Type = "Overview"
    )

    Get-AuthToken($Account)
    
    switch ($Type) {
        "Overview"{
            $URI = (Get-CloudURI("monitoring")) + "/views/overview"

            break;
        }
        "Limits"{
            $URI = (Get-CloudURI("monitoring")) + "/limits"
            break;
        }
        "Audits"{
            $URI = (Get-CloudURI("monitoring")) + "/audits"
            break;
        }
        "Account"{
            $URI = (Get-CloudURI("monitoring")) + "/account"
            break;
        }
        default {
            throw "Overview type not recognised"
            break;
        }
    }

    (Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -ErrorAction Stop)

 <#
 .SYNOPSIS
 Retrieve Cloud Monitoring overview, limit and audit details.

 .DESCRIPTION
 The Get-CloudMonDetail cmdlet will retreive Rackspace Cloud Monitoring overview, current limits or audit log for a given cloud account.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER Type
 Mandatory parameter that defines the type of query you would like to perform. If -Type is not provided, Overview option is assumed.
 Valid options are:
    Overview - Return the overview for the account (All entities with checks and alarms)
    Limits - list of current limits aplied to Cloud Monitoring service and current usage levels
    Audits - list of all write API operations (PUT, POST, DELETE) for the last 30 days
    Account - returns information about specified account

 .EXAMPLE
 PS C:\> Get-CloudMonDetail -Account prod -Type Overview
 This example shows how to retrieve an overview of current monitoring configuration for 'prod' account, as a custom PS object.

 .EXAMPLE
 PS C:\> Get-CloudMonDetail -Account prod -Type Limits
 This example shows how to retrieve current monitoring limits for 'prod' account, as a custom PS object.

 .LINK
 http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/overview.html
#>
}

function Show-CloudMonZone {
    Param(
        [Parameter(Position=0, Mandatory=$True)][string] $Account = $(throw "-Account is required."),
        [Parameter(Position=1, Mandatory=$False)][string] $ZoneID
    )

    Get-AuthToken($Account)
    $URI = (Get-CloudURI("monitoring")) + "/monitoring_zones"
    $result = (Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -ErrorAction Stop).values


    if ($ZoneID){
        return ($result | where id -like $ZoneID);
    }
    else {
        return $result;
    }

 <#
 .SYNOPSIS
 Show Cloud Monitoring zone details.

 .DESCRIPTION
 The Show-CloudMonZone cmdlet will show currently available Rackspace Cloud Monitoring zones, or collectors, for use in configuration of checks.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER ZoneID
 Use this parameter to filter output by a specific zone, identified by it's ID. 

 .EXAMPLE
 PS C:\> Show-CloudMonZone -Account prod
 This example shows how to retrieve an overview of current monitoring configuration for 'prod' account, as a custom PS object.

 .EXAMPLE
 PS C:\> Show-CloudMonZone -Account prod -ZoneID mzsyd
 This example shows how to retrieve an overview for just the Sydney monitoring zone.

 .LINK
 http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/overview.html
#>

}

function Request-CloudMonZoneTracert {
    Param(
        [Parameter(Position=0, Mandatory=$True)][string] $Account = $(throw "-Account is required."),
        [Parameter(Position=1, Mandatory=$True)][string] $ZoneID,
        [Parameter(Position=2, Mandatory=$True)][string] $Target
    )

    Get-AuthToken($Account)
    $URI = (Get-CloudURI("monitoring")) + "/monitoring_zones/$ZoneID/traceroute"

    $JSONbody = ((New-Object -TypeName PSCustomObject -Property @{"target"=$Target}) | ConvertTo-Json)

    (Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $JSONBody -ContentType application/json -Method Post -ErrorAction Stop).result

 <#
 .SYNOPSIS
 Initiate a traceroute test form a Cloud Monitoring zone.

 .DESCRIPTION
 The Request-CloudMonZoneTracert cmdlet will initiate a trace route test from the specified monitoring zone.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER ZoneID
 Use this parameter to specify the source monitoring zone for this test, identified by zone ID.. 

 .PARAMETER Target
 Use this parameter to filter output by a specific zone, identified by it's ID.. 

 .EXAMPLE
 PS C:\> Request-CloudMonZoneTracert -Account prod -ZoneID mzsyd -Target 8.8.8.8
 This example shows how to retrieve an overview of current monitoring configuration for 'prod' account, as a custom PS object.

 .EXAMPLE
 PS C:\> Request-CloudMonZoneTracert -Account prod -ZoneID mzsyd -Target www.microsoft.com
 This example shows how to retrieve an overview for just the Sydney monitoring zone.

 .LINK
 http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/overview.html
#>

}

function Add-CloudMonEntity {
    Param(
        [Parameter(Position=0, Mandatory=$True)][string] $Account,
        [Parameter(Position=1, Mandatory=$True)][string] $Label,
        [Parameter(Position=2, Mandatory=$False)][string] $AgentID,
        [Parameter(Position=3, Mandatory=$False)][HashTable] $IPAddresses,
        [Parameter(Position=4, Mandatory=$False)][HashTable] $Metadata
    )

    Get-AuthToken($Account)
    $URI = (Get-CloudURI("monitoring")) + "/entities"

    $object = (New-Object -TypeName PSCustomObject -Property @{"label"=$Label})

    if ($AgentID){
        $object | Add-Member –MemberType NoteProperty –Name agent_id –Value $AgentID
    }

    if ($IPAddresses){
        $object | Add-Member -MemberType NoteProperty -Name ip_addresses -Value $IPAddresses
    }

    if ($Metadata){
        $object | Add-Member –MemberType NoteProperty –Name metadata –Value $Metadata
    }

    $JSONbody = ($object | ConvertTo-Json)

    Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $JSONBody -ContentType application/json -Method Post -ErrorAction Stop
 <#
 .SYNOPSIS
 Add a new Cloud Monitoring entity.

 .DESCRIPTION
 The Add-CloudMonEntity cmdlet will create a Cloud Monitoring entity.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER Label
 Use this parameter to specify the label that you wish to associate with your new entity. 

 .PARAMETER AgentID
 Use this optional parameter to specify the Agent to which this entity will be bound.

 .PARAMETER IPAddresses
 Use this parameter to specify the IP addresses that you wish to associate with your new entity. 
 This parameter will only accept hash table objects as input, which can either be specified as 
 a hash inline (@{"public" = "192.168.0.1"; "private" = "10.10.10.1"}) or passed as a variable.

 .PARAMETER Metadata
 Use this parameter to specify any metadata that you wish to associate with your new entity. 
 This parameter will only accept hash table objects as input, which can either be specified as 
 a hash inline (@{"meta1" = "your value"; "some other key" = "another value"}) or passed as a variable.

 .EXAMPLE
 PS C:\> Add-CloudMonEntity -Account prod -Label test
 This example shows how to add an entity called 'test' under the 'prod' account.

 .EXAMPLE
 PS C:\> Add-CloudMonEntity -Account prod -Label test -IPAddresses @{"public" = "192.168.0.1"; "private" = "10.10.10.1"}
 This example shows how to add an entity called 'test' under the 'prod' account, and specify two IP addresses.

 .LINK
 http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/overview.html
#>
}

function Show-CloudMonEntity {
    Param(
        [Parameter(Position=0, Mandatory=$True)][string] $Account,
        [Parameter(Position=1, Mandatory=$False)][string] $EntityID
    )

    Get-AuthToken($Account)

    $URI = (Get-CloudURI("monitoring")) + "/entities"

    if ($EntityID){
        $URI += "/$EntityID"
        Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -ErrorAction Stop
    }
    else{
        (Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -ErrorAction Stop).values
    }

 <#
 .SYNOPSIS
 Retrieve Cloud Monitoring entities and list details.

 .DESCRIPTION
 The Show-CloudMonEntities cmdlet will list the entities for a particular account.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER EntityID
 Use this parameter to retreive details of a specific entity, identified by it's ID.

 .EXAMPLE
 PS C:\> Show-CloudMonEntity -Account prod
 This example shows how to list entities for 'prod' account.

 .EXAMPLE
 PS C:\> Show-CloudMonEntity -Account prod -EntityID enDZ8BpK3M
 This example shows how to list details of a single entity under 'prod' account, identified by 'enDZ8BpK3M'

 .LINK
 http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/overview.html
#>
}

function Remove-CloudMonEntity {
    Param(
        [Parameter(Position=0, Mandatory=$True)][string] $Account,
        [Parameter(Position=1, Mandatory=$True)][string] $EntityID
    )

    Get-AuthToken($Account)

    $URI = (Get-CloudURI("monitoring")) + "/entities/$EntityID"

    Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Method Delete -ErrorAction Stop

 <#
 .SYNOPSIS
 Remove a Cloud Monitoring entity.

 .DESCRIPTION
 The Remove-CloudMonEntity cmdlet will remove the specified entity.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER EntityID
 Use this parameter to retreive details of a specific entity, identified by it's ID.

 .EXAMPLE
 PS C:\> Remove-CloudMonEntity -Account prod -EntityID enDZ5BpK3M
 This example shows how to remove an entity under 'prod' account, identified by 'enDZ5BpK3M'

 .LINK
 http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/overview.html
#>
}

function Edit-CloudMonEntity {
    Param(
        [Parameter(Position=0, Mandatory=$True)][string] $Account,
        [Parameter(Position=1, Mandatory=$True)][string] $EntityID,
        [Parameter(Position=2, Mandatory=$False)][string] $AgentID,
        [Parameter(Position=3, Mandatory=$False)][HashTable] $Metadata
    )

    Get-AuthToken($Account)
    $URI = (Get-CloudURI("monitoring")) + "/entities/$EntityID"

    $object = @{}

    if ($AgentID -or $Metadata -or $Label){
        if ($AgentID){
            $object.agent_id = $AgentID
        }
        if ($Metadata){
            $object | Add-Member -MemberType NoteProperty -Name metadata -Value $Metadata
        }
    }
    else {
        throw "AgentID or Metadata parameter must be provided"
    }

    $JSONbody = ($object | ConvertTo-Json)

    Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $JSONBody -ContentType application/json -Method Put -ErrorAction Stop

 <#
 .SYNOPSIS
 Edit a Cloud Monitoring entity.

 .DESCRIPTION
 The Edit-CloudMonEntity cmdlet will modify an entity. as per API documentation for Rackspace Managed Cloud entities, 
 many fields will be managed by Rackspace, so only the fields 'metadata' and 'agent_id' may be updated via the API.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER EntityID
 Use this parameter to retreive details of a specific entity, identified by it's ID.

 .PARAMETER AgentID
 Use this optional parameter to specify a new Agent ID to which this entity will be bound.

 .PARAMETER Metadata
 Use this optional parameter to modify the metadata for the entity.

 .EXAMPLE
 PS C:\> Edit-CloudMonEntity -Account prod -EntityID enDZ5BpK3M -Metadata @{"meta1" = "your value"; "some other key" = "another value"}
 This example shows how to remove an entity under 'prod' account, identified by 'enDZ5BpK3M' and modify/add user-defined metadata.

 .LINK
 http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/overview.html
#>
}

<#
    Create Entity - Add-CloudMonEntity
    Get Details Of Entity - Show-CloudMonEntity
    List Entities - Show-CloudMonEntity
    Update Entity - Edit-CloudMonEntity
    Delete Entity - Remove-CloudMonEntity
#>

<#
function Get-CloudMonAccount {
    Param(
        [Parameter(Position=0, Mandatory=$True)][string] $Account = $(throw "-Account is required."),
        [Parameter(Position=1, Mandatory=$True)][ValidateSet("Overview","Limits","Audits")][string]$Type
    )


    Get-AuthToken($Account)


}
#>
