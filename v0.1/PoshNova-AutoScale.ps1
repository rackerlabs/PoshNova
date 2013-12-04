<############################################################################################

                           ___          _         __                
                          / _ \___  ___| |__   /\ \ \_____   ____ _ 
                         / /_)/ _ \/ __| '_ \ /  \/ / _ \ \ / / _` |
                        / ___/ (_) \__ \ | | / /\  / (_) \ V / (_| |
                        \/    \___/|___/_| |_\_\ \/ \___/ \_/ \__,_|
                                                           AutoScale

Authors
-----------
    Nielsen Pierce (nielsen.pierce@rackspace.co.uk)
    Alexei Andreyev (alexei.andreyev@rackspace.co.uk)
    
Description
-----------
PowerShell v3 module for interaction with NextGen Rackspace Cloud API (PoshNova) 

AutoScale API reference
----------------------
http://docs.rackspace.com/cas/api/v1.0/autoscale-devguide/content/Gen_API_Info-de01.html

############################################################################################>




function Get-CloudScalingLimits{

    Param(
        [Parameter (Position=0, Mandatory=$True)][string] $account = $(throw "Please specify required Cloud Account with -account parameter")
    )

	 try {
        
        # Retrieving authentication token
        Get-AuthToken($account)
	
    
        # Setting variables needed to execute this function
        $URI = (Get-CloudURI("autoscale")) + "/limits"
	
    $ScalingLimits = (Invoke-RestMethod -Uri $URI  -Headers $HeaderDictionary).limits.rate
    $ScalingLimits| select uri -ExpandProperty limit | ft -AutoSize

    }
    catch {
        Invoke-Exception($_.Exception)
}
    

    <#
 .SYNOPSIS
 The Get-CloudScalingLimits cmdlet will retrieve current scaling limits for your account.

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. Valid choices are defined in PoshNova configuration file.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudScalingLimits -Account prod
 This example shows how to get a list of all absolute limits for account prod.

 .LINK
 http://docs.rackspace.com/cas/api/v1.0/autoscale-devguide/content/Rate_Limits-d1e1222.html
#>

}

function Get-CloudScalingGroups {

Param(
        [Parameter (Position=0, Mandatory=$True)][string] $account = $(throw "Please specify required Cloud Account with -account parameter")
    )

	 try {
        
        # Retrieving authentication token
        Get-AuthToken($account)
	
    
        # Setting variables needed to execute this function
        $URI = (Get-CloudURI("autoscale")) + "/groups"
		
        ## Making the call to the API for a list of available Scaling Groups and storing data into a variable
        $Grouplist = (Invoke-RestMethod -Uri $URI  -Headers $HeaderDictionary).groups
    
    
        
        ## Handling empty response bodies indicating that no groups exist in the account
        if ($GroupList -eq $null) {

            Write-Host "You do not currently have any Scaling Groups provisioned in the $CloudDDI account."

        }
    

        elseif($GroupList -ne $null){
                
            ## Since the response body is XML, we can use dot walk to show the information needed without further parsing.
		    $GroupList | select name, id, active, paused, pendingCapacity, activeCapacity | ft -AutoSize
        
        }

        }

        catch {
            Invoke-Exception($_.Exception)
        }

 <#
 .SYNOPSIS
 The Get-CloudScalingGroups cmdlet will retrieve current scaling groups for your account.

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. Valid choices are defined in PoshNova configuration file.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudScalingGroups -Account prod
 This example shows how to get a list of all scaling groups for account prod.

 .LINK
 http://docs.rackspace.com/cas/api/v1.0/autoscale-devguide/content/GET_getGroups_v1.0__tenantId__groups_Groups.html
#>
}

function Add-CloudScalingGroup {

    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$GroupName,
        [Parameter(Position=1,Mandatory=$true)]
        [int]$GroupFlavorID,
        [Parameter(Position=2,Mandatory=$true)]
        [string]$GroupImageID,
        [Parameter(Position=3,Mandatory=$true)]
        [int]$LoadBalancerID,
        [Parameter (Position=4, Mandatory=$true)]
        [int]$LoadBalancerPort,
        [Parameter (Position=5, Mandatory=$true)]
        [string] $Account = $(throw "Please specify required Cloud Account with -account parameter")
    )

     try {
        
        # Retrieving authentication token
        Get-AuthToken($account)
	
    
        # Setting variables needed to execute this function
        $URI = (Get-CloudURI("autoscale")) + "/groups"


$JSONBody = '
{
"launchConfiguration": {
"args": {
"loadBalancers": [
{
"port":'+ $LoadBalancerPort +',
"loadBalancerId": '+ $LoadBalancerID +'
}
],
"server": {
"name": "as_server",
"imageRef": "'+ $GroupImageID +'",
"flavorRef": "'+ $GroupFlavorID +'",
"OS-DCF:diskConfig": "AUTO",
"metadata": {
"build_config": "core",
"meta_key_1": "meta_value_1",
"meta_key_2": "meta_value_2"
},
"networks": [
{
"uuid": "11111111-1111-1111-1111-111111111111"
},
{
"uuid": "00000000-0000-0000-0000-000000000000"
}
],
"personality": [
{
"path": "/root/.csivh",
"contents": "VGhpcyBpcyBhIHRlc3QgZmlsZS4="
}
]
}
},
"type": "launch_server"
},
"groupConfiguration": {
"maxEntities": 10,
"cooldown": 360,
"name": "'+ $Groupname +'",
"minEntities": 0,
"metadata": {
"gc_meta_key_2": "gc_meta_value_2",
"gc_meta_key_1": "gc_meta_value_1"
}
},
"scalingPolicies": [
{
"cooldown": 0,
"type": "webhook",
"name": "'+ $Groupname +'",
"change": 1
}
]
}
'

        $Global:NewSG = Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $JSONBody -ContentType application/json -Method Post -ErrorAction Stop
        $NewSG.group.state
        $NewSG.group.groupConfiguration
    }
    
    catch {
            Invoke-Exception($_.Exception)
    }
<#
 .SYNOPSIS
 The Add-CloudScalingGroup cmdlet will add a scaling group for your account.

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. Valid choices are defined in PoshNova configuration file.
  
 .PARAMETER GroupFlavorID
 Use this parameter to specify the Server Flavor

 .PARAMETER GroupImageID
 Use this parameter to specify the Server image

 .PARAMETER LoadBalancerID
 Use this parameter to specify the Loadbalancer

 .PARAMETER LoadBalancerPort
 Use this parameter to specify the Loadbalancer port
 
 .EXAMPLE
 PS C:\Users\Administrator> Add-CloudScalingGroup -Groupname test -GroupFalvorID 3 -GroupimageId 41af66f7-6122-48de-b79c-13c98a5febbe -LoadBalancerID 1001 -LoadbalancerPort 80 -Account prod
 This example will create a new group called Test for account prod.

 .LINK
 http://docs.rackspace.com/cas/api/v1.0/autoscale-devguide/content/POST_createGroup_v1.0__tenantId__groups_Groups.html
#>

}

function Get-CloudScalingGroupDetails {

    Param(
        [Parameter (Position=0, Mandatory=$true)]
        [string] $GroupID,
        [Parameter (Position=1, Mandatory=$true)]
        [string] $Account  = $(throw "Please specify required Cloud Account with -account parameter")
    )

    try {
        
        # Retrieving authentication token
        Get-AuthToken($account)
	
    
        # Setting variables needed to execute this function
        $URI = (Get-CloudURI("autoscale")) + "/groups/$GroupID"
    
    	
        ## Making the call to the API for a list of available Scaling Groups and storing data into a variable
        $Grouplist = (Invoke-RestMethod -Uri $URI  -Headers $HeaderDictionary).group
            
    
         ## Handling empty response bodies indicating that group id does not exist in the queried data center
        if ($GroupList.scalingPolicies -eq $null) {

            Write-Host "Cannot find Scaling Group $GroupID in the $CloudDDI account."

        }
    

        elseif($GroupList -ne $null){
                
            ## Since the response body is JSON, we can use dot walk to show the information needed without further parsing.
		    $GroupList.scalingPolicies
        
            }
        }

        catch {
            Invoke-Exception($_.Exception)
        }


<#
 .SYNOPSIS
 The Get-CloudScalingGroupDetails cmdlet will retrieve a scaling group for your account.

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. Valid choices are defined in PoshNova configuration file.

 .PARAMETER GroupId
 This parameter specifies the ID of the group 

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudScalingGroupDetails -Account prod -GroupID 6b8c2bb5-8572-4327-bb0a-c5454f9b2cb6
 This example will show the polices for an existing group in the account prod.

 .LINK
 http://docs.rackspace.com/cas/api/v1.0/autoscale-devguide/content/GET_getGroupManifest_v1.0__tenantId__groups__groupId__Groups.html
#>

    }

function Remove-CloudScalingGroup {

    Param(
        [Parameter (Position=0, Mandatory=$true)]
        [string] $GroupID,
        [Parameter (Position=1, Mandatory=$true)]
        [string] $Account = $(throw "Please specify required Cloud Account with -account parameter")
    )

    try {
        
        # Retrieving authentication token
        Get-AuthToken($account)
	
    
        # Setting variables needed to execute this function
        $URI = (Get-CloudURI("autoscale")) + "/groups/$GroupID"
    
		
        Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Method Delete -ErrorAction Stop
        Write-host "`nScaling Group $GroupID has been deleted"

    }

    catch {
            Invoke-Exception($_.Exception)
        }

<#
 .SYNOPSIS
 The Remove-CloudScalingGroup cmdlet will remove a scaling group for your account.

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. Valid choices are defined in PoshNova configuration file.

 .PARAMETER GroupId
 This parameter specifies the ID of the group 

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudScalingGroup -Account prod -GroupID 6b8c2bb5-8572-4327-bb0a-c5454f9b2cb6
 This example will remove a group from account prod.

 .LINK
 http://docs.rackspace.com/cas/api/v1.0/autoscale-devguide/content/DELETE_deleteGroup_v1.0__tenantId__groups__groupId__Groups.html
#>

		
}

    
function Get-CloudScalingGroupState {

    Param(
        [Parameter (Position=0, Mandatory=$true)]
        [string] $GroupID,
        [Parameter (Position=1, Mandatory=$true)]
        [string] $Account  = $(throw "Please specify required Cloud Account with -account parameter")
    )

    try {
        
        # Retrieving authentication token
        Get-AuthToken($account)
	
    
        # Setting variables needed to execute this function
        $URI = (Get-CloudURI("autoscale")) + "/groups/$GroupID/state"
    
    		
        ## Making the call to the API for a list of available Scaling Groups and storing data into a variable
        $GroupState = (Invoke-RestMethod -Uri $URI  -Headers $HeaderDictionary).group
            
    
        ## Handling empty response bodies indicating that group id does not exist in the queried data center
        if ($GroupState -eq $null) {

            Write-Host "Cannot find Scaling Group $GroupID in the $CloudDDI account."

        }
    

        elseif($GroupState -ne $null){
                
            ## Since the response body is JSON, we can use dot walk to show the information needed without further parsing.
		    $GroupState
        
            }
        }

    catch {
            Invoke-Exception($_.Exception)
        }

<#
 .SYNOPSIS
 The Get-CloudScalingGroupState cmdlet will display the group state for your account.

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. Valid choices are defined in PoshNova configuration file.

 .PARAMETER GroupId
 This parameter specifies the ID of the group 

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudScalingGroupState -Account prod -GroupID 6b8c2bb5-8572-4327-bb0a-c5454f9b2cb6
 This example will display the state a group from account prod.

 .LINK
 http://docs.rackspace.com/cas/api/v1.0/autoscale-devguide/content/GET_getGroupState_v1.0__tenantId__groups__groupId__state_Groups.html
#>

}

    

    
function Suspend-CloudScalingGroupPolicyExecution {

    Param(
        [Parameter (Position=0, Mandatory=$true)]
        [string] $GroupID,
        [Parameter (Position=1, Mandatory=$true)]
        [string] $Account = $(throw "Please specify required Cloud Account with -account parameter")
    )

    try {
        
        # Retrieving authentication token
        Get-AuthToken($account)
	
    
        # Setting variables needed to execute this function
        $URI = (Get-CloudURI("autoscale")) + "/groups/$GroupID/pause"
        $URIk

        }
           
    catch {
            Invoke-Exception($_.Exception)
        }
    
		
        ## Making the call to the API for and pause Scaling Group Execution
        Invoke-RestMethod -Uri $URI  -Headers $HeaderDictionary -Method Post -ErrorAction Stop    

<#
 .SYNOPSIS
 The Suspend-CloudScalingGroupPolicyExecution cmdlet will pause a scaling group for your account.

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. Valid choices are defined in PoshNova configuration file.

 .PARAMETER GroupId
 This parameter specifies the ID of the group 

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudScalingGroupState -Account prod -GroupID 6b8c2bb5-8572-4327-bb0a-c5454f9b2cb6
 This example will pause the execution policy for spefified group in account prod.

 .LINK
 http://docs.rackspace.com/cas/api/v1.0/autoscale-devguide/content/POST_pauseGroup_v1.0__tenantId__groups__groupId__pause_Groups.html
#>
    
}

function Resume-CloudScalingGroupPolicyExecution {

    Param(
        [Parameter (Position=0, Mandatory=$true)]
        [string] $GroupID,
        [Parameter (Position=1, Mandatory=$true)]
        [string] $Account = $(throw "Please specify required Cloud Account with -account parameter")
    )

    try {
        
        # Retrieving authentication token
        Get-AuthToken($account)
	
    
        # Setting variables needed to execute this function
        $URI = (Get-CloudURI("autoscale")) + "/groups/$GroupID/resume"
    
		
        ## Making the call to the API for and resume Scaling Group Execution
        Invoke-RestMethod -Uri $URI  -Headers $HeaderDictionary -Method Post -ErrorAction Stop    
        }

    catch {
            Invoke-Exception($_.Exception)
        }
<#
 .SYNOPSIS
 The Resume-CloudScalingGroupPolicyExecution cmdlet will unpause a scaling group for your account.

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. Valid choices are defined in PoshNova configuration file.

 .PARAMETER GroupId
 This parameter specifies the ID of the group 

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudScalingGroupState -Account prod -GroupID 6b8c2bb5-8572-4327-bb0a-c5454f9b2cb6
 This example will unpause the execution policy for spefified group in account prod.

 .LINK
 http://docs.rackspace.com/cas/api/v1.0/autoscale-devguide/content/POST_resumeGroup_v1.0__tenantId__groups__groupId__resume_Groups.html
#>

    
}

function Get-CloudScalingGroupConfig {

    Param(
        [Parameter (Position=0, Mandatory=$true)]
        [string] $GroupID,
        [Parameter (Position=1, Mandatory=$true)]
        [string] $Account = $(throw "Please specify required Cloud Account with -account parameter")
    )

    try {
        
        # Retrieving authentication token
        Get-AuthToken($account)
	
        # Setting variables needed to execute this function
        $URI = (Get-CloudURI("autoscale")) + "/groups/$GroupID/config"
    

		
        ## Making the call to the API for a list of available Scaling Groups and storing data into a variable
        $Groupconfig = (Invoke-RestMethod -Uri $URI  -Headers $HeaderDictionary).groupConfiguration
       
    
        ## Handling empty response bodies indicating that group id does not exist in the queried data center
        if ($GroupConfig -eq $null) {

        Write-Host "Cannot find Scaling Group $GroupID in the $CloudDDI account."

    }
    

    elseif($Groupconfig -ne $null){
                
        ## display configuration
		$Groupconfig
        
        }

    }
    catch {
            Invoke-Exception($_.Exception)
        }

<#
 .SYNOPSIS
 The Get-CloudScalingGroupConfig cmdlet will retrieve scaling group conifuration for your account.

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. Valid choices are defined in PoshNova configuration file.

 .PARAMETER GroupId
 This parameter specifies the ID of the group 

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudScalingGroupState -Account prod -GroupID 6b8c2bb5-8572-4327-bb0a-c5454f9b2cb6
 This example will get config of specified group from account prod.

 .LINK
 http://docs.rackspace.com/cas/api/v1.0/autoscale-devguide/content/GET_getGroupConfig_v1.0__tenantId__groups__groupId__config_Configurations.html
#>


}

function Replace-CloudScalingGroupConfig {

    Param(
        [Parameter (Position=0, Mandatory=$true)]
        [string] $GroupID,
        [Parameter (Position=1, Mandatory=$true)]
        [string] $NameID,
        [Parameter (Position=2, Mandatory=$true)]
        [string] $Cooldown,
        [Parameter (Position=3, Mandatory=$true)]
        [string] $MinEntities,
        [Parameter (Position=4, Mandatory=$true)]
        [string] $MaxEntities,
        [Parameter (Position=5, Mandatory=$true)]
        [string] $Account = $(throw "Please specify required Cloud Account with -account parameter")
    )

    try {
        
        # Retrieving authentication token
        Get-AuthToken($account)
	
    
        # Setting variables needed to execute this function
        $URI = (Get-CloudURI("autoscale")) + "/groups/$GroupID/config"
    

    	
$JSONBody = ' [

    {
"name": "'+ $name +'",
"cooldown": '+ $Cooldown +',
"minEntities": '+ $MinEntities +',
"maxEntities": '+ $MaxEntities +'
"metadata": {
"firstkey": "this is a string",
"secondkey": "1",
            }
    }

]'

        ## Making the call to the API for a list of available Scaling Groups and storing data into a variable
        $Groupconfig = (Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $JSONBody -ContentType application/json -Method Post -ErrorAction Stop)

        }
    
    catch {
            Invoke-Exception($_.Exception)
        }
<#
 .SYNOPSIS
 The Replace-CloudScalingGroupConfig cmdlet will retrieve scaling group conifuration for your account.

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. Valid choices are defined in PoshNova configuration file.

 .PARAMETER GroupId
 This parameter specifies the ID of the group 

 .PARAMETER NameID
 This parameter defines groups new name

 .PARAMETER Cooldown
 This parameter defines the cooldown time period (secs)

 .PARAMETER MinEntities
 This parameter defines minimum number of entities
 
 .PARAMETER MaxEntities
 This parameter defines maximum number of entities

 .EXAMPLE
 PS C:\Users\Administrator> Replace-CloudScalingGroupConfig -Account prod -GroupID 6b8c2bb5-8572-4327-bb0a-c5454f9b2cb6 -name Test -Cooldown 60 -Minentites 5 -MaxEntities 100
 This example will replace group config of specified group from account prod with new name Test, cooldown of 60 secs, minimum number of entities of 5 and mamimum number of entities 100

 .LINK
 http://docs.rackspace.com/cas/api/v1.0/autoscale-devguide/content/PUT_putGroupConfig_v1.0__tenantId__groups__groupId__config_Configurations.html
#>
            
}

function Get-CloudScalingLaunchConfig {

    Param(
        [Parameter (Position=0, Mandatory=$true)]
        [string] $GroupID,
        [Parameter (Position=1, Mandatory=$true)]
        [string] $Account
    )

    Get-CloudAccount
    
    ## Setting variables needed to execute this function
    Set-Variable -Name SGLURI -Value "https://$region.autoscale.api.rackspacecloud.com/v1.0/$CloudDDI/groups/$GroupID/launch"
    

    ## Retrieving authentication token
    Get-AuthToken


    ## Setting Cloud Account
	$global:acc = $account
		
    ## Making the call to the API for a list of available Scaling Groups and storing data into a variable
    $GroupLaunchStep0 = (Invoke-RestMethod -Uri $SGLURI  -Headers $HeaderDictionary)
    $global:GroupLaunchFinal = ($GroupLaunchStep0.innerxml)

    
    
     ## Handling empty response bodies indicating that group id does not exist in the queried data center
    if ($GroupLaunchFinal.Groups -eq $null) {

        Write-Host "Cannot find Scaling Group $GroupID in the $CloudDDI account."

    }
    

    elseif($GroupLaunchFinal.Groups -ne $null){
                
        ## Since the response body is JSON, we can use dot walk to show the information needed without further parsing.
		$GroupLaunchFinal.Groups 
        
        }



    }

function Replace-CloudScalingLaunchConfig {

    Param(
        [Parameter (Position=0, Mandatory=$true)]
        [string] $GroupID,
        [Parameter (Position=1, Mandatory=$true)]
        [string] $Name,
        [Parameter (Position=2, Mandatory=$true)]
        [string] $FlavorID,
        [Parameter (Position=3, Mandatory=$true)]
        [string] $ImageID,
        [Parameter (Position=4, Mandatory=$true)]
        [string] $LoadBalancerID,
        [Parameter (Position=5, Mandatory=$true)]
        [string] $Port,
        [Parameter (Position=7, Mandatory=$true)]
        [string] $Account
    )

    Get-CloudAccount
    
    ## Setting variables needed to execute this function
    Set-Variable -Name SGLURI -Value "https://$region.autoscale.api.rackspacecloud.com/v1.0/$CloudDDI/groups/$GroupID/launch"
    

    ## Retrieving authentication token
    Get-AuthToken


    ## Setting Cloud Account
	$global:acc = $account
	
    $NewSGLCJSONBody = ' [

{
"type": "launch_server",
"args": {
"server": {
"flavorRef": '+ $FlavorID +',
"name": "'+ $name +'",
"imageRef": "'+ $ImageID +'",
"OS-DCF:diskConfig": "AUTO",
"metadata": {
"mykey": "myvalue"
},
"personality": [
{
"path": "/root/.ssh/authorized_keys",
"contents": "ssh-rsa AAAAB3Nza...LiPk== user@example.net"
}
],
"networks": [
{
"uuid": "11111111-1111-1111-1111-111111111111"
}
],
},
"loadBalancers": [
{
"loadBalancerId": '+ $LoadBalancerID +'
"port": '+ $Port +'
}
]
}
}

]'

    ## Making the call to the API for a list of available Scaling Groups and storing data into a variable
    $GroupLaunchStep0 = (Invoke-RestMethod -Uri $SGLURI -Headers $HeaderDictionary -Body $NewSGLCJSONBody -ContentType application/json -Method Post -ErrorAction Stop)
    $global:GroupLaunchFinal = ($GroupLaunchStep0.innerxml)
        
    }

function Get-CloudScalingPoliciesList {

    Param(
        [Parameter (Position=0, Mandatory=$true)]
        [string] $GroupID,
        [Parameter (Position=1, Mandatory=$true)]
        [string] $Account
    )

    Get-CloudAccount
    
    ## Setting variables needed to execute this function
    Set-Variable -Name SGPURI -Value "https://$region.autoscale.api.rackspacecloud.com/v1.0/$CloudDDI/groups/$GroupID/policies"
    

    ## Retrieving authentication token
    Get-AuthToken


    ## Setting Cloud Account
	$global:acc = $account
		
    ## Making the call to the API for a list of available Scaling Groups and storing data into a variable
    $Global:GroupPoliciesStep0 = (Invoke-RestMethod -Uri $SGPURI  -Headers $HeaderDictionary)
    $global:GroupPoliciesFinal = ($GroupPoliciesStep0.policies)

    
    
     ## Handling empty response bodies indicating that group id does not exist in the queried data center
    if ($GroupPoliciesFinal -eq $null) {

        Write-Host "Cannot find Scaling Group $GroupID in the $CloudDDI account."

    }
    

    elseif($GroupPoliciesFinal -ne $null){
                
        ## Since the response body is JSON, we can use dot walk to show the information needed without further parsing.
		$GroupPoliciesFinal 
        
        }



    }

function Add-CloudScalingPolicy {

    Param(
        [Parameter (Position=0, Mandatory=$true)]
        [string] $GroupID,
        [Parameter (Position=0, Mandatory=$true)]
        [string] $PolicyConfigFile,
        [Parameter (Position=2, Mandatory=$true)]
        [string] $Account
    )

    Get-CloudAccount
    
    ## Setting variables needed to execute this function
    Set-Variable -Name SGPURI -Value "https://$region.autoscale.api.rackspacecloud.com/v1.0/$CloudDDI/groups/$GroupID/policies"
    

    ## Retrieving authentication token
    Get-AuthToken

    ## Setting Cloud Account
	$global:acc = $account

    $PolicyJSONBody = Get-Content -Path $PolicyConfigFile

    $global:NewPolicyConf = Invoke-RestMethod -Uri $SGPURI -Headers $HeaderDictionary -Body $PolicyJSONBody -ContentType application/json -Method Post -ErrorAction Stop
    $global:NewPolicy = $NewPolicyConf

    $newpolicy.polocies

    }

function Get-CloudScalingPolicyDetails {

    Param(
        [Parameter (Position=0, Mandatory=$true)]
        [string] $GroupID,
        [Parameter (Position=1, Mandatory=$true)]
        [string] $PolicyID,
        [Parameter (Position=2, Mandatory=$true)]
        [string] $Account
    )

    Get-CloudAccount
    
    ## Setting variables needed to execute this function
    Set-Variable -Name SGPDetailsURI -Value "https://$region.autoscale.api.rackspacecloud.com/v1.0/$CloudDDI/groups/$GroupID/policies/$PolicyID"
    

    ## Retrieving authentication token
    Get-AuthToken


    ## Setting Cloud Account
	$global:acc = $account
		
    ## Making the call to the API for a list of available Scaling Groups and storing data into a variable
    $GroupPolicyDetailsStep0 = (Invoke-RestMethod -Uri $SGPDetailsURI  -Headers $HeaderDictionary)
    $global:GroupPolicyDetailsFinal = ($GroupPolicyDetailsStep0.policy)

    
    
     ## Handling empty response bodies indicating that group id does not exist in the queried data center
    if ($GroupPolicyDetailsFinal -eq $null) {

        Write-Host "Cannot find Scaling Group $PolicyID in the $CloudDDI account."

    }
    

    elseif($GroupPolicyDetailsFinal -ne $null){
                
        ## Since the response body is JSON, we can use dot walk to show the information needed without further parsing.
		$GroupPolicyDetailsFinal
        
        }



    }

function Replace-CloudScalingPolicy  {

    Param(
        [Parameter (Position=0, Mandatory=$true)]
        [string] $GroupID,
        [Parameter (Position=1, Mandatory=$true)]
        [string] $PolicyID,
        [Parameter (Position=2, Mandatory=$true)]
        [string] $Name,
        [Parameter (Position=3, Mandatory=$true)]
        [string] $ChangePercent,
        [Parameter (Position=4, Mandatory=$true)]
        [string] $Cooldown,
        [Parameter (Position=5, Mandatory=$true)]
        [string] $Type,      
        [Parameter (Position=6, Mandatory=$true)]
        [string] $Account
    )

    Get-CloudAccount
    
    ## Setting variables needed to execute this function
    Set-Variable -Name SGPURI -Value "https://$region.autoscale.api.rackspacecloud.com/v1.0/$CloudDDI/groups/$GroupID/policies/$policyid"
    

    ## Retrieving authentication token
    Get-AuthToken


    ## Setting Cloud Account
	$global:acc = $account
	
    $NewSGPJSONBody = ' [

    {
"name": "'+ $name +'",
"changePercent": '+ $ChangePercent +',
"cooldown": '+ $Cooldown +',
"type": "'+ $Type +'"
}

    ]'
    

    ## Making the call to the API to replace Policy and storing data into a variable
    $GroupLPolicyStep0 = (Invoke-RestMethod -Uri $SGPURI -Headers $HeaderDictionary -Body $NewSGPJSONBody -ContentType application/json -Method Post -ErrorAction Stop)
    $global:GroupLPolicyFinal = ($GroupLPolicy.innerxml)
        
    }

function Remove-CloudScalingPolicy   {

    Param(
        [Parameter (Position=0, Mandatory=$true)]
        [string] $GroupID,
        [Parameter (Position=1, Mandatory=$true)]
        [string] $PolicyID,
        [Parameter (Position=6, Mandatory=$true)]
        [string] $Account
    )

    Get-CloudAccount
    
    ## Setting variables needed to execute this function
    Set-Variable -Name DelSGPURI -Value "https://$region.autoscale.api.rackspacecloud.com/v1.0/$CloudDDI/groups/$GroupID/policies/$policyid"
    

    ## Retrieving authentication token
    Get-AuthToken


    ## Setting Cloud Account
	$global:acc = $account
	    

    ## Making the call to the API to remove Policy
    Invoke-RestMethod -Uri $DelSGPURI -Headers $HeaderDictionary -Method Delete -ErrorAction Stop
    
        
    }

function Invoke-CloudScalingPolicy   {

    Param(
        [Parameter (Position=0, Mandatory=$true)]
        [string] $GroupID,
        [Parameter (Position=1, Mandatory=$true)]
        [string] $PolicyID,
        [Parameter (Position=6, Mandatory=$true)]
        [string] $Account
    )

    Get-CloudAccount
    
    ## Setting variables needed to execute this function
    Set-Variable -Name EXSGPURI -Value "https://$region.autoscale.api.rackspacecloud.com/v1.0/$CloudDDI/groups/$GroupID/policies/$policyid/execute"
    

    ## Retrieving authentication token
    Get-AuthToken


    ## Setting Cloud Account
	$global:acc = $account
	    

    ## Making the call to the API to remove Policy
    $GroupPolicyExStep0 = (Invoke-RestMethod -Uri $EXSGPURI -Headers $HeaderDictionary -method Post -ErrorAction Stop)
    $global:GroupPolicyExFinal = ($GroupPolicyExStep0.innerxml)
        
    }

function Get-CloudScalingWebhooks {

    Param(
        [Parameter (Position=0, Mandatory=$true)]
        [string] $GroupID,
        [Parameter (Position=1, Mandatory=$true)]
        [string] $PolicyID,
        [Parameter (Position=2, Mandatory=$true)]
        [string] $Account
    )

    Get-CloudAccount
    
    ## Setting variables needed to execute this function
    Set-Variable -Name WebHooksURI -Value "https://$region.autoscale.api.rackspacecloud.com/v1.0/$CloudDDI/groups/$GroupID/policies/$PolicyID/webhooks"
    

    ## Retrieving authentication token
    Get-AuthToken


    ## Setting Cloud Account
	$global:acc = $account
		
    ## Making the call to the API for a list of available Scaling Groups and storing data into a variable
    $Global:WebHooksStep0 = (Invoke-RestMethod -Uri $WebHooksURI  -Headers $HeaderDictionary)
    $global:WebHooksFinal = ($WebHooksStep0.webhooks)

    
    
     ## Handling empty response bodies indicating that group id does not exist in the queried data center
    if ($WebHooksFinal -eq $null) {

        Write-Host "Cannot find Group $PolicyID in the $CloudDDI account."

    }
    

    elseif($WebHooksFinal -ne $null)    {
                
        ## Since the response body is JSON, we can use dot walk to show the information needed without further parsing.
		$WebHooksFinal | select name, id, metadata | FT -AutoSize
        
        }



    }

function Add-CloudScalingWebhook {

    Param(
        [Parameter (Position=0, Mandatory=$true)]
        [string] $GroupID,
        [Parameter (Position=1, Mandatory=$true)]
        [string] $PolicyID,
        [Parameter (Position=2, Mandatory=$true)]
        [string] $Name,
        [Parameter (Position=3, Mandatory=$false)]
        [string] $Notes,
        [Parameter (Position=4, Mandatory=$true)]
        [string] $Account
    )

    Get-CloudAccount
    
    ## Setting variables needed to execute this function
    Set-Variable -Name AddWebHooksURI -Value "https://$region.autoscale.api.rackspacecloud.com/v1.0/$CloudDDI/groups/$GroupID/policies/$PolicyID/webhooks"
    

    ## Retrieving authentication token
    Get-AuthToken


    ## Setting Cloud Account
	$global:acc = $account
	

$WebHookJSONBody = ' [
{
"name": "' + $name +'",
"metadata": {
    "notes": "'+ $notes +'"
    }
}
]'

    ## Making the call to the API to add Webhook and storing data into a variable
    $WebHooksStep0 = (Invoke-RestMethod -Uri $AddWebHooksURI  -Headers $HeaderDictionary -Body $WebHookJSONBody -ContentType application/json -Method Post -ErrorAction Stop)
    $global:WebHooksFinal = ($WebHooksStep0.webhook)
    }

function Get-CloudScalingWebhook {

    Param(
        [Parameter (Position=0, Mandatory=$true)]
        [string] $GroupID,
        [Parameter (Position=1, Mandatory=$true)]
        [string] $PolicyID,
        [Parameter (Position=2, Mandatory=$true)]
        [string] $WebhookID,
        [Parameter (Position=3, Mandatory=$true)]
        [string] $Account
    )

    Get-CloudAccount
    
    ## Setting variables needed to execute this function
    Set-Variable -Name GetWebHookURI -Value "https://$region.autoscale.api.rackspacecloud.com/v1.0/$CloudDDI/groups/$GroupID/policies/$PolicyID/webhooks/$webhookid"
    
    
    ## Retrieving authentication token
    Get-AuthToken


    ## Setting Cloud Account
	$global:acc = $account
		
    ## Making the call to the API for a list of available Scaling Groups and storing data into a variable
    $global:WebHookStep0 = (Invoke-RestMethod -Uri $GetWebHookURI -Headers $HeaderDictionary)
    $global:WebHookFinal = ($WebHookStep0.webhook)

    
    
     ## Handling empty response bodies indicating that group id does not exist in the queried data center
    if ($WebHookFinal -eq $null) {

        Write-Host "Cannot find Scaling Group $WebhookID in the $CloudDDI account."

    }
    

    elseif($WebHookFinal -ne $null){
                
        ## Since the response body is JSON, we can use dot walk to show the information needed without further parsing.
		$WebHookFinal | select name, id, metadata | ft
        
        }



    }

function Update-CloudScalingWebhook {

    Param(
        [Parameter (Position=0, Mandatory=$true)]
        [string] $GroupID,
        [Parameter (Position=1, Mandatory=$true)]
        [string] $PolicyID,
        [Parameter (Position=2, Mandatory=$true)]
        [string] $Name,
        [Parameter (Position=3, Mandatory=$true)]
        [string] $WebHookID,
        [Parameter (Position=4, Mandatory=$false)]
        [string] $Notes,
        [Parameter (Position=5, Mandatory=$true)]
        [string] $Account
    )

    Get-CloudAccount
    
    ## Setting variables needed to execute this function
    Set-Variable -Name UpdateWebHooksURI -Value "https://$region.autoscale.api.rackspacecloud.com/v1.0/$CloudDDI/groups/$GroupID/policies/$PolicyID/webhooks/$webhookID"
    

    ## Retrieving authentication token
    Get-AuthToken


    ## Setting Cloud Account
	$global:acc = $account
	

$WebHookJSONBody = '[
{
"name": "'+ $name +'",
"metadata": {
"notes": "'+ $Notes +'"
    }
]'

    ## Making the call to the API to add Webhook and storing data into a variable
    $WebHooksStep0 = (Invoke-RestMethod -Uri $UpdateWebHooksURI  -Headers $HeaderDictionary  -Body $WebHookJSONBody -ContentType application/json -Method Post -ErrorAction Stop)
    $global:WebHooksFinal = ($WebHooksStep0.innerxml)
    
    }

function Remove-CloudScalingWebhook {

    Param(
        [Parameter (Position=0, Mandatory=$true)]
        [string] $GroupID,
        [Parameter (Position=1, Mandatory=$true)]
        [string] $PolicyID,
        [Parameter (Position=1, Mandatory=$true)]
        [string] $WebhookID,
        [Parameter (Position=3, Mandatory=$true)]
        [string] $Account
    )

    Get-CloudAccount
    
    ## Setting variables needed to execute this function
    Set-Variable -Name DelWebHooksURI -Value "https://$region.autoscale.api.rackspacecloud.com/v1.0/$CloudDDI/groups/$GroupID/policies/$PolicyID/webhooks/$webhookid"
    

    ## Retrieving authentication token
    Get-AuthToken


    ## Setting Cloud Account
	$global:acc = $account
		
    ## Making the call to the API for a list of available Scaling Groups and storing data into a variable
    Invoke-RestMethod -Uri $DelWebHookURI  -Headers $HeaderDictionary -Method Delete -ErrorAction Stop
    
        
    }