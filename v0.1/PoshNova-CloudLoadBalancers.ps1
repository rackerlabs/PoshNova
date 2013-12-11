<############################################################################################

                           ___          _         __                
                          / _ \___  ___| |__   /\ \ \_____   ____ _ 
                         / /_)/ _ \/ __| '_ \ /  \/ / _ \ \ / / _` |
                        / ___/ (_) \__ \ | | / /\  / (_) \ V / (_| |
                        \/    \___/|___/_| |_\_\ \/ \___/ \_/ \__,_|
                                                Cloud Load Balancers

Authors
-----------
    Nielsen Pierce (nielsen.pierce@rackspace.co.uk)
    Alexei Andreyev (alexei.andreyev@rackspace.co.uk)
    Description
-----------
PowerShell v3 module for interaction with NextGen Rackspace Cloud API (PoshNova) 

CLB v1.0 API reference
----------------------
http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Overview-d1e82.html

Get-CloudLoadBalancerDetails

- Needs testing


- Complete

Get-CloudLoadBalancerACLs
Get-CloudLoadBalancerNodeEvents
Get-CloudLoadBalancerNodeList
Get-CloudLoadBalancerProtocols
Get-CloudLoadBalancers
Get-CloudLoadBalancerHealthMonitor
Get-CloudLoadBalancerSSLTermination
Get-CloudLoadBalancerAlgorithms
Get-CloudLoadBalancerProtocols
Remove-CloudLoadBalancerACL
Remove-CloudLoadBalancerACLItem
Remove-CloudLoadBalancer
Remove-CloudLoadBalancerNode
Remove-CloudLoadBalancerHealthMonitor
Remove-CloudLoadBalancerContentCaching
Remove-CloudLoadBalancerSessionPersistence
Remove-CloudLoadBalancerConnectionLogging
Remove-CloudLoadBalancerConnectionThrottling
Remove-CloudLoadBalancerSSLTermination
Add-CloudLoadBalancerNode
Add-Remove-CloudLoadBalancerContentCaching
Add-CloudLoadBalancerConnectionLogging
Add-CloudLoadBalancerConnectionThrottling
Add-CloudLoadBalancerSessionPersistence
Add-CloudLoadBalancerSSLTermination
Add-CloudLoadBalancerHealthMonitor
Add-CloudLoadBalancerACLItem
Add-CloudLoadBalancer
Update-CloudLoadBalancerConnectionThrottling
Update-CloudLoadBalancerSessionPersistence
Update-CloudLoadBalancerNode
Update-CloudLoadBalancer
Update-CloudLoadBalancerSSLTermination


############################################################################################>

function Get-CloudLoadBalancers{

    Param(
        [Parameter (Position=0, Mandatory=$True)][string] $Account = $(throw "-Account required"),
        [Parameter (Position=1, Mandatory=$False)][string]$RegionOverride
    )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

         
    # Retrieving authentication token
    Get-AuthToken($account)


    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("loadbalancers")) + "/loadbalancers"

    # Making the call to the API for a list of available server images and storing data into a variable
	$LBList = (Invoke-RestMethod -Uri $URI  -Headers $HeaderDictionary)
        
    # Since the response body is XML, we can use dot notation to show the information needed without further parsing.
	return $LBList.loadBalancers;
 
    
<#
 .SYNOPSIS
 The Get-CloudLoadBalancers cmdlet will pull down a list of all Rackspace Cloud Load Balancers on your account.

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancers -Account prod
 This example shows how to get a list of all load balancers currently deployed in your account within the lon region.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancers cloudus -RegionOverride DFW
 This example shows how to get a list of all available images for cloudus account in DFW region
  
 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/List_Load_Balancers-d1e1367.html

#>
}

function Get-CloudLoadBalancerDetails {

    Param(
        [Parameter (Position=0, Mandatory=$True)][string] $Account = $(throw "-Account required"),
        [Parameter(Position=1,Mandatory=$true)][string]$CloudLBID,
        [Parameter (Position=2, Mandatory=$False)][string]$RegionOverride
    )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

         
    # Retrieving authentication token
    Get-AuthToken($account)


    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("loadbalancers")) + "/loadbalancers/$CloudLBID"
    
    $LBDetail = (Invoke-RestMethod -Uri $URI  -Headers $HeaderDictionary -Method Get)
       

    # Handling empty response bodies indicating that no servers exist in the queried data center
    if ($LBDetail.loadBalancer -eq $null) {
        Write-Host "You have entered an incorrect Cloud Load Balancer ID."
        break;
    }

    $LBDetail.loadBalancer
        
<#
 .SYNOPSIS
 The Get-CloudLoadBalancerDetails cmdlet will pull down a list of detailed information for a specific Rackspace Cloud Load Balancer.

 .DESCRIPTION
See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to indicate the ID of the cloud load balancer of which you want explicit details. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against.  Valid choices are defined in Conf.xml

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancerDetails -CloudLBID 12345 -Account prod
 This example shows how to get explicit data about one cloud load balancer from the prod account

  
 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/List_Load_Balancer_Details-d1e1522.html
#>
}

function Get-CloudLoadBalancerProtocols{

    Param(
        [Parameter (Position=0, Mandatory=$True)][string] $Account = $(throw "-Account required"),
        [Parameter (Position=1, Mandatory=$False)][string]$RegionOverride
    )

   if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }
        
   # Retrieving authentication token
   Get-AuthToken($account)
       

   # Setting variables needed to execute this function
   $URI = (Get-CloudURI("loadbalancers")) + "/loadbalancers/protocols"
        
   # Making the call to the API for a list of available server images and storing data into a variable
   $LBProtocolList = (Invoke-RestMethod -Uri $URI  -Headers $HeaderDictionary).protocols

   # Since the response body is JSON, we can use dot notation to show the information needed without further parsing.
   return $LBProtocolList | Sort-Object Name | ft -AutoSize;
    
    
<#
 .SYNOPSIS
 The Get-CloudLoadBalancerProtocols cmdlet will pull down a list of all available Rackspace Cloud Load Balancer protocols.

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancerProtocols -Account prod
 This example shows how to get a list of all load balancer protocols available for use.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancerProtocols cloudus -RegionOverride DFW
 This example shows how to get a list of all available images for cloudus account in DFW region

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/List_Load_Balancing_Protocols-d1e4269.html

#>
}

function Get-CloudLoadBalancerAlgorithms{

    Param(
        [Parameter (Position=0, Mandatory=$True)][string] $Account = $(throw "-Account required"),
        [Parameter (Position=1, Mandatory=$False)][string]$RegionOverride
    )

   if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }
           
    # Retrieving authentication token
    Get-AuthToken($account)
       

    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("loadbalancers")) + "/loadbalancers/algorithms"
        

    # Making the call to the API for a list of available load balancers and storing data into a variable
    LBAlgorithmList = (Invoke-RestMethod -Uri $URI  -Headers $HeaderDictionary).algorithms
   

    # Since the response body is XML, we can use dot notation to show the information needed without further parsing.
    return $LBAlgorithmList | Sort-Object Name | ft -AutoSize;

   
<#
 .SYNOPSIS
 The Get-CloudLoadBalancerAlgorithms cmdlet will pull down a list of all available Rackspace Cloud Load Balancer algorithms.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancerAlgorithms
 This example shows how to get a list of all load balancer algorithms available for use.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancerAlgorithms cloudus -RegionOverride DFW
 This example shows how to get a list of all available images for cloudus account in DFW region
 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/List_Load_Balancing_Algorithms-d1e4459.html

#>
}

function Add-CloudLoadBalancer {
    
    Param(
        [Parameter(Position=0,Mandatory=$true)][string]$Account,
        [Parameter(Position=1,Mandatory=$true)][string]$CloudLBName,
        [Parameter(Position=2,Mandatory=$true)][int]$CloudLBPort,
        [Parameter(Position=3,Mandatory=$false)][string][ValidateSet("DNS_TCP", "DNS_UDP", "FTP", "HTTP", "HTTPS", "IMAPS", "IMAPv2", "IMAPv3", "IMAPv4", "LDAP", "LDAPS", "MYSQL", "POP3", "POP3S", "SFTP", "SMTP", "TCP", "TCP_CLIENT_FIRST", "UDP", "UDP_STREAM")]$CloudLBProtocol,
        [Parameter(Position=4,Mandatory=$false)][string][ValidateSet("LEAST_CONNECTIONS", "RANDOM", "ROUND_ROBIN", "WEIGHTED_LEAST_CONNECTIONS","WEIGHTED_ROUND_ROBIN")]$CloudLBAlgorithm,
        [Parameter(Position=5,Mandatory=$false)][string][ValidateSet("ENABLED", "DISABLED")]$CloudLBNodeCondition,
        [Parameter(Position=6,Mandatory=$true)][string]$CloudLBNodeIP,
        [Parameter(Position=7,Mandatory=$true)][int]$CloudLBNodePort,
        [Parameter(Position=8,Mandatory=$False)][string]$RegionOverride
        
    )
              
    # Retrieving authentication token
    Get-AuthToken($account)
       

    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("loadbalancers")) + "/loadbalancers"

    # Setting variables needed to execute this function
    
    $object = New-Object -TypeName PSCustomObject -Property @{
        "loadBalancer"=New-Object -TypeName PSCustomObject -Property @{
            "name"=$CloudLBName;
	        "port"=$CloudLBPort;
	        "protocol"=$CloudLBProtocol.ToUpper();
            "algorithm"=$CloudLBAlgorithm.ToUpper();
            "virtualIps"=@();
            "nodes"=@()
            }
        }
        
    $object.loadBalancer.virtualIps += New-Object -TypeName PSCustomObject -Property @{
        "type"="PUBLIC"
        }

    $object.loadBalancer.nodes += New-Object -TypeName PSCustomObject -Property @{
            "address"=$CloudLBNodeIP;
            "port"=$CloudLBNodePort; 
            "condition"=$CloudLBNodeCondition.ToUpper()
             }
             
    JSONbody = $object | ConvertTo-Json -Depth 3

    $NewCloudLB = Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $JSONBody -ContentType application/json -Method Post -ErrorAction Stop
    $NewCloudLB.loadBalancer

    
 <#
 .SYNOPSIS
 The Add-CloudLoadBalancer cmdlet will create a new Rackspace cloud load balancer in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBName
 Use this parameter to define the name of the load balancer you are about to create. Whatever you enter here will be exactly what is displayed as the server name in further API requests and/or the Rackspace Cloud Control Panel.

 .PARAMETER CloudLBPort
 Use this parameter to define the TCP/UDP port number of the load balancer you are creating.

.PARAMETER CloudLBProtocol
 Use this parameter to define the protocol that will bind to this load balancer.  If you are unsure, you can get a list of supported protocols and ports by running the "Get-LoadBalancerProtocols" cmdlet.

 .PARAMETER CloudLBAlgorithm
 Use this parameter to define the load balancing algorithm you'd like to use with your load balancer.  If you are unsure, you can get a list of supported algorithms by running the "Get-CloudLoadBalancerAlgorithms" cmdlet.

 LEAST_CONNECTIONS
 RANDOM
 ROUND_ROBIN
 WEIGHTED_LEAST_CONNECTIONS
 WEIGHTED_ROUND_ROBIN

 .PARAMETER CloudLBNodeIP
 Use this parameter to define the private IP address of the first node you wish to have served by this load balancer. This must be a functional and legitimate IP, or this command will fail run properly.

 .PARAMETER CloudLBNodePort
 Use this parameter to define the port number of the first node you wish to have served by this load balancer.

 .PARAMETER CloudLBNodeCondition
 Use this parameter to define the condition of the first node you wish to have served by this load balancer. Accepted values in this field are:

 "ENABLED"  - Node is permitted to accept new connections
 "DISABLED" - Node is nor permitted to accept any new connections. Existing connections are forcibly terminated.

.PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against.  Valid choices are defined in Conf.xml

 .EXAMPLE
 PS C:\Users\Administrator> Add-CloudLoadBalancer -CloudLBName TestLB -CloudLBPort 80 -CloudLBProtocol HTTP -CloudLBAlgorithm RANDOM -CloudLBNodeIP 10.1.1.10 -CloudLBNodePort 80 -CloudLBNodeCondition ENABLED  -Account prod
 This example shows how to spin up a new load balancer called TestLB, balancing incoming HTTP port 80 traffic randomly to a server with a private IP address of 10.1.1.10 on port 80, in the account prod

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Create_Load_Balancer-d1e1635.html

#>
}

function Get-CloudLoadBalancerNodeList{

    Param(
        [Parameter (Position=0, Mandatory=$True)][string] $Account = $(throw "-Account required"),
        [Parameter(Position=1,Mandatory=$true)][string]$CloudLBID,
        [Parameter (Position=2, Mandatory=$False)][string]$RegionOverride
    )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

            
    # Retrieving authentication token
    Get-AuthToken($account)
        
    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("loadbalancers")) + "/loadbalancers/$CloudLBID/nodes"

    # Making the call to the API for a list of available server images and storing data into a variable
	NodeList = (Invoke-RestMethod -Uri $URI  -Headers $HeaderDictionary)

    # Since the response body is JSON, we can use dot notation to show the information needed without further parsing.
	return $NodeList.Nodes;

   

<#
 .SYNOPSIS
 The Get-CloudLoadBalancerNodeList cmdlet will pull down a list of all nodes that are currently provisioned behind the specified load balancer.

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER CloudLBID
 Use this parameter to indicate the ID of the cloud load balancer of which you want explicit details. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.
 
 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancerNodeList -CloudLBID 12345 -Account prod
 This example shows how to get a list of all nodes currently provisioned behind a load balancer with an ID of 12345, from the account prod.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancerNodeList cloudus -RegionOverride DFW
 This example shows how to get a list of all available images for cloudus account in DFW region

 
 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/List_Nodes-d1e2218.html

#>
}

function Add-CloudLoadBalancerNode {
    
    Param(
        [Parameter (Position=0, Mandatory=$True)][string] $Account = $(throw "-Account required"),
        [Parameter(Position=1,Mandatory=$true)][int]$CloudLBID,
        [Parameter(Position=2,Mandatory=$true)][string]$CloudLBNodeIP,
        [Parameter(Position=3,Mandatory=$true)][int]$CloudLBNodePort,
        [Parameter(Position=4,Mandatory=$true)][string]$CloudLBNodeCondition,
        [Parameter(Position=5,Mandatory=$true)][string]$CloudLBNodeType,
        [Parameter(Position=6,Mandatory=$false)][int]$CloudLBNodeWeight,
        [Parameter(Position=7,Mandatory=$false)][string]$RegionOverride
    )

     if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
        }

    # Retrieving authentication token
    Get-AuthToken($account)

    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("loadbalancers")) + "/loadbalancers/$CloudLBID/nodes"

    
    $object = New-Object -TypeName PSCustomObject -Property @{
            "nodes"=@()
            }

    $object.nodes += New-Object -TypeName PSCustomObject -Property @{
            "address"=$CloudLBNodeIP;
            "port"=$CloudLBNodePort;
            "condition"=$CloudLBNodeCondition;
            "weight"=$CloudLBNodeWeight;
            "type"=$CloudLBNodeType
             }
   
    $JSONbody = $object | ConvertTo-Json -Depth 3
    
    $NewCloudLBNode = Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $JSONbody -ContentType application/json -Method Post -ErrorAction Stop
   	Write-Host "The node has been added as follows:"
    return $NewCloudLBNode.nodes
	

<#
 .SYNOPSIS
 The Add-CloudLoadBalancerNode cmdlet will add a new node to a cloud load balancer in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to define the name of the load balancer you are about to modify. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

 .PARAMETER CloudLBNodeIP
 Use this parameter to define the private IP address of the first node you wish to have served by this load balancer. This MUST be a functional and legitimate IP, or this command will fail run properly.

 .PARAMETER CloudLBNodePort
 Use this parameter to define the port number of the first node you wish to have served by this load balancer.

 .PARAMETER CloudLBNodeCondition
 Use this parameter to define the condition of the first node you wish to have served by this load balancer. Accepted values in this field are:

 "ENABLED"  - Node is permitted to accept new connections
 "DISABLED" - Node is not permitted to accept any new connections. Existing connections are forcibly terminated.

 .Parameter CloudLBNodeType
 Use this parameter to define the type of node you are adding to the load balancer.  Allowable node types are:
 
 "PRIMARY"   - Nodes defined as PRIMARY are in the normal rotation to receive traffic from the load balancer.
 "SECONDARY" - Nodes defined as SECONDARY are only in the rotation to receive traffic from the load balancer when all the primary nodes fail.
 
 .PARAMETER CloudLBNodeWeight
 Use this parameter to definte the weight of the node you are adding to the load balancer.  This parameter is only required if you are adding a node to a load balancer that is utilizing a weighted load balancing algorithm.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file.

 .EXAMPLE
 Add-CloudLoadBalancerNode -Account prod -CloudLBID 12345 -CloudLBNodeIP 1.1.1.3 -CloudLBNodePort 80 -CloudLBNodeCondition ENABLED -CloudLBNodeType PRIMARY -CloudLBNodeWeight 10
 This example shows how to add a node (1.1.1.3) to Load Balancer 12345 as a Primary node on port 80 for the account prod

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Add_Nodes-d1e2379.html

#>
}

function Remove-CloudLoadBalancerNode {

    Param(
        [Parameter (Position=0, Mandatory=$True)][string] $Account = $(throw "-Account required"),
        [Parameter(Position=1,Mandatory=$true)][string]$CloudLBID,
        [Parameter(Position=1,Mandatory=$true)][string]$CloudLBNodeID,
        [Parameter (Position=2, Mandatory=$False)][string]$RegionOverride
        
    )

     if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

        
    # Retrieving authentication token
    Get-AuthToken($account)
       

    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("loadbalancers")) + "/loadbalancers/$CloudLBID/nodes/$CloudLBNodeID"

    $DelCloudLBNode = Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Method Delete
    Write-Host "The node has been deleted."
	
<#
 .SYNOPSIS
 The Remove-CloudLoadBalancerNode cmdlet will remove a node from a cloud load balancer in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to define the name of the load balancer you are about to modify. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

 .PARAMETER CloudLBNodeID
 Use this parameter to define the ID of the node you wish to remove from the load balancer configuration.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "lon" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudLoadBalancerNode -CloudLBID 123456 -CloudLBNodeID 5 -Region lon
 This example shows how to spin up a new load balancer called TestLB, balancing incoming HTTP port 80 traffic randomly to a server with a private IP address of 10.1.1.10 on port 80, in the lon region.

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Remove_Nodes-d1e2675.html

#>
}

function Remove-CloudLoadBalancer {

    Param(
         [Parameter (Position=0, Mandatory=$True)][string] $Account = $(throw "-Account required"),
         [Parameter(Position=1,Mandatory=$true)][string]$CloudLBID,
         [Parameter (Position=2, Mandatory=$False)][string]$RegionOverride
    )


    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }
        
    # Retrieving authentication token
    Get-AuthToken($account)
        
    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("loadbalancers")) + "/loadbalancers/$CloudLBID"

        
    $DelCloudLB = Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Method Delete
    Write-Host "The load balancer has been deleted."

<#
 .SYNOPSIS
 The Remove-CloudLoadBalancer cmdlet will remove a cloud load balancer in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to define the name of the load balancer you are about to remove. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file.

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudLoadBalancer -CloudLBID 123456 -Region lon
 This example shows how to remove a load balancer with an ID of 12345 in the account prod

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudLoadBalancer cloudus -RegionOverride DFW
 This example shows how to get a list of all available images for cloudus account in DFW region

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Remove_Load_Balancer-d1e2093.html

#>
}

function Update-CloudLoadBalancer {
    
    Param(
        [Parameter (Position=0, Mandatory=$True)][string] $Account = $(throw "-Account required"),
        [Parameter(Position=2,Mandatory=$true)][int]$CloudLBID,
        [Parameter(Position=3,Mandatory=$false)][string]$CloudLBName,
        [Parameter(Position=4,Mandatory=$false)][int]$CloudLBPort,
        [Parameter(Position=5,Mandatory=$false)][string][ValidateSet("DNS_TCP", "DNS_UDP", "FTP", "HTTP", "HTTPS", "IMAPS", "IMAPv2", "IMAPv3", "IMAPv4", "LDAP", "LDAPS", "MYSQL", "POP3", "POP3S", "SFTP", "SMTP", "TCP", "TCP_CLIENT_FIRST", "UDP", "UDP_STREAM")]$CloudLBProtocol,
        [Parameter(Position=6,Mandatory=$false)][string][ValidateSet("LEAST_CONNECTIONS", "RANDOM", "ROUND_ROBIN", "WEIGHTED_LEAST_CONNECTIONS","WEIGHTED_ROUND_ROBIN")]$CloudLBAlgorithm,
        [Parameter(Position=7,Mandatory=$false)][int]$CloudLBTimeout,
        [Parameter(Position=8,Mandatory=$false)][string]$RegionOverride
    )
        
    
    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
        }
        
    # Retrieving authentication token
    Get-AuthToken($account)

    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("loadbalancers")) + "/loadbalancers/$CloudLBID"

    $LBObject = New-Object -TypeName PSCustomObject -Property @{}
    $LBObject | Add-Member -MemberType NoteProperty -Name "name" -Value $CloudLBName
         
    if ($CloudLBPort) {        
        $LBObject | Add-Member -MemberType NoteProperty -Name "port" -Value $CloudLBPort
        }
            
     if ($CloudLBProtocol) {
        $LBObject | Add-Member -MemberType NoteProperty -Name "protocol" -Value $CloudLBProtocol.ToUpper()
        }

    if ($CloudLBAlgorithm) {
        $LBObject | Add-Member -MemberType NoteProperty -Name "algorithm" -Value $CloudLBAlgorithm.ToUpper()
        }

    if ($CloudLBTimeout) {
        $LBObject | Add-Member -MemberType NoteProperty -Name "timeout" -Value $CloudLBTimeout
        }  
        
    $object = New-Object -TypeName PSCustomObject -Property @{
        "loadBalancer"= $LBObject
        }

    JSONbody = $object | ConvertTo-Json -Depth 3
        
    $UpdateCloudLB = Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $JSONBody -ContentType application/json -Method Put -ErrorAction Stop

    Write-Host "Your load balancer has been updated"

<#
 .SYNOPSIS
 The Update-CloudLoadBalancer cmdlet will update a cloud load balancer in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to define the ID of the load balancer you are about to modify. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

 .PARAMETER CloudLBName
 Use this parameter to define the name of the specified load balancer.

 .PARAMETER CloudLBPort
 Use this parameter to define the TCP/UDP port number of the specified load balancer.

.PARAMETER CloudLBProtocol
 Use this parameter to define the protocol of the specified load balancer.  If you are unsure, you can get a list of supported protocols and ports by running the "Get-CloudLoadBalancerProtocols" cmdlet.

 .PARAMETER CloudLBAlgorithm
 Use this parameter to define the load balancing algorithm you'd like to use with your load balancer.  If you are unsure, you can get a list of supported algorithms by running the "Get-CloudLoadBalancerAlgorithms" cmdlet.

 LEAST_CONNECTIONS
 RANDOM
 ROUND_ROBIN
 WEIGHTED_LEAST_CONNECTIONS
 WEIGHTED_ROUND_ROBIN

 .PARAMETER CloudLBTimeout
 Use this parameter to define the timeout value of the specified load balancer.

.PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file.

  .EXAMPLE
 PS C:\Users\Administrator> Update-CloudLoadBalancer -Account cloudus -CloudLBName Test2 -CloudLBID 83093 -CloudLBPort 81 -CloudLBTimeout 35 -RegionOverride DFW
 This example shows how to update load balancer with new name, port and timeout value for DFW

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Update_Load_Balancer_Attributes-d1e1812.html

#>
}

function Update-CloudLoadBalancerNode {
    
    Param(
        [Parameter (Position=0, Mandatory=$True)][string] $Account = $(throw "-Account required"),
        [Parameter(Position=1,Mandatory=$false)][int]$CloudLBID,
        [Parameter(Position=2,Mandatory=$false)][int]$CloudLBNodeID,
        [Parameter (Position=3,Mandatory=$false)][string][ValidateSet("ENABLED", "DISABLED", "DRAINING")]$CloudLBNodeCondition,
        [Parameter(Position=4,Mandatory=$false)][string][ValidateSet("PRIMARY", "SECONDARY")]$CloudLBNodeType,
        [Parameter(Position=5,Mandatory=$false)][int]$CloudLBNodeWeight,
        [Parameter(Position=6,Mandatory=$false)][string]$RegionOverride
    )

    

     if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
        }

    # Retrieving authentication token
    Get-AuthToken($account)

    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("loadbalancers")) + "/loadbalancers/$CloudLBID/nodes/$CloudLBNodeID"

    if ($CloudLBNodeWeight){
        $object = New-Object -TypeName PSCustomObject -Property @{
            "node"=New-Object -TypeName PSCustomObject -Property @{
                "condition"=$CloudLBNodeCondition.toupper();
                "weight"=$CloudLBNodeWeight
                }
            }
    }

    elseif ($CloudLBNodeType) {
         $object = New-Object -TypeName PSCustomObject -Property @{
            "node"=New-Object -TypeName PSCustomObject -Property @{
                "condition"=$CloudLBNodeCondition.toupper();
                "type"=$CloudLBNodeType.toupper()
                }
            }
    }

    elseif (($CloudLBNodeType) -and ($CloudLBNodeWeight)){
         $object = New-Object -TypeName PSCustomObject -Property @{
            "node"=New-Object -TypeName PSCustomObject -Property @{
                "condition"=$CloudLBNodeCondition.toupper();
                "weight"=$CloudLBNodeWeight;
                "type"=$CloudLBNodeType.toupper()
                }
            }
    }

    else {
         $object = New-Object -TypeName PSCustomObject -Property @{
            "node"=New-Object -TypeName PSCustomObject -Property @{
                "condition"=$CloudLBNodeCondition.toupper()
                 }
            }
    }

    JSONbody = $object | ConvertTo-Json
    
    Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $JSONBody -ContentType application/json -Method Put -ErrorAction Stop

    Write-Host "Your node has been updated."

    
<#
 .SYNOPSIS
 The Update-CloudLoadBalancerNode cmdlet will update a cloud load balancer in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to define the ID of the load balancer you are about to modify. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

 .PARAMETER CloudLBNodeID
 Use this parameter to define the ID of the node you are about to modify.

 .PARAMETER CloudLBNodeCondition
 Use this parameter to define the condition of the specified node. At all times, you must have at least one ENABLED node within a load balancer's configuration. Accepted values in this field are:

 "ENABLED"  - Node is permitted to accept new connections
 "DISABLED" - Node is not permitted to accept any new connections. Existing connections are forcibly terminated.
 "DRAINING" - Node is allowed to service existing established connections and connections that are being directed to it as a result of the session persistence configuration.

 .Parameter CloudLBNodeType
 Use this parameter to define the type of the specified node.  At all times, you must have at least one PRIMARY node within a load balancer's configuration. Allowable node types are:
 
 "PRIMARY"   - Nodes defined as PRIMARY are in the normal rotation to receive traffic from the load balancer.
 "SECONDARY" - Nodes defined as SECONDARY are only in the rotation to receive traffic from the load balancer when all the primary nodes fail.

 .Parameter CloudLBNodeWeight
 Use this parameter to definte the weight of the node you are adding to the load balancer.  This parameter is only required if you are adding a node to a load balancer that is utilizing a weighted load balancing algorithm.

 .PARAMETER CloudLBTimeout
 Use this parameter to define the timeout value of the specified load balancer.

 .PARAMETER ChangeName
 Use this switch to specify that you are changing the name of the load balancer.
  
.PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file.

 .EXAMPLE
 PS C:\Users\Administrator> Update-CloudLoadBalancer -ChangeType -CloudLBID 12345 -CloudLBNodeID 1234 -CloudLBNodeType SECONDARY -account prod
  This example shows how to modify a load balancer node to become SECONDARY in the account prod.

 .LINK
http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Modify_Nodes-d1e2503.html

#>
}

function Get-CloudLoadBalancerNodeEvents{

    Param(
        [Parameter (Position=0, Mandatory=$True)][string] $Account = $(throw "-Account required"),
        [Parameter(Position=1,Mandatory=$true)][string]$CloudLBID,
        [Parameter (Position=2, Mandatory=$False)][string]$RegionOverride
    )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

        
    # Retrieving authentication token
    Get-AuthToken($account)
       

    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("loadbalancers")) + "/loadbalancers/$CloudLBID/nodes/events"

    # Making the call to the API for a list of available load balancers and storing data into a variable
    $NodeEventS = Invoke-RestMethod -Uri $URI  -Headers $HeaderDictionary
    

    # Since the response body is JSON, we can use dot notation to show the information needed without further parsing.     
    return $NodeEvents.NodeServiceEvents

<#
 .SYNOPSIS
 The Get-CloudLoadBalancerNodeEvents cmdlet will retrieve all service events from the specified load balancer.

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER CloudLBID
 Use this parameter to indicate the ID of the cloud load balancer of which you want explicit details. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.
 
 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancerNodeEvents -CloudLBID 12345 -Account prod
 This example shows how to get a list of all nodes currently provisioned behind a load balancer with an ID of 12345, from the account prod.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancerNodeEvents cloudus -CloudLBID 12345 -RegionOverride DFW
 This example shows how to get a list of all available images for cloudus account in DFW region

  
 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Node-Events-d1e264.html

#>
}

function Get-CloudLoadBalancerACLs {

    Param(
        [Parameter (Position=0, Mandatory=$True)][string] $Account = $(throw "-Account required"),
        [Parameter(Position=1,Mandatory=$true)][string]$CloudLBID,
        [Parameter (Position=2, Mandatory=$False)][string]$RegionOverride
    )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

        
    # Retrieving authentication token
    Get-AuthToken($account)
       

    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("loadbalancers")) + "/loadbalancers/$CloudLBID/accesslist"
             
    $AccessListS = Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Method Get -ErrorAction Stop
    
    if (!$AccessList.accessList.networkItem) {
        Write-Host "This load balancer does not currently have any ACLs configured." -ForegroundColor Red
    }
    else {
       return $AccessList.accessList.networkItem | ft -AutoSize
    }

<#
 .SYNOPSIS
 The Get-CloudLoadBalancerACLs cmdlet will retrieve all configured ACL items from a cloud load balancer in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to define the ID of the load balancer you are querying. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against.  Valid choices are defined in Conf.xml

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancerACLs -CloudLBID 51885 -Account prod
 This example shows how to get all ACL items from the specified load balancer in the prod account

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Manage_Access_Lists-d1e3187.html

#>
}

function Add-CloudLoadBalancerACLItem {

    Param(
        [Parameter (Position=0, Mandatory=$True)][string] $Account = $(throw "-Account required"),
        [Parameter(Position=0,Mandatory=$true)][string]$CloudLBID,
        [Parameter(Position=1,Mandatory=$true)][string]$IP,
        [Parameter(Position=2,Mandatory=$true)][string][ValidateSet("ALLOW", "DENY")]$Action,
        [Parameter(Position=6,Mandatory=$false)][string]$RegionOverride
    )


    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

        
    # Retrieving authentication token
    Get-AuthToken($account)
       

    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("loadbalancers")) + "/loadbalancers/$CloudLBID/accesslist"
    

    $object = New-Object -TypeName PSCustomObject -Property @{
        "accessList"=@()
        }

    $object.accessList += New-Object -TypeName PSCustomObject -Property @{
            "address"=$IP;
            "type"=$Action.toupper()  
            }
        
 
    JSONbody = $object | ConvertTo-Json -Depth 3
             
    Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $JSONBody -ContentType application/json -Method Post -ErrorAction Stop

    Write-Host "The ACL item has been added."

       

<#
 .SYNOPSIS
 The Add-CloudLoadBalancerACL cmdlet will add/append an ACL item for a cloud load balancer in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to define the ID of the load balancer you are modifying. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

 .PARAMETER IP
 Use this parameter to define the IP address for item to add to access list.  This can a single IP, such as "5.5.5.5" or a CIDR notated range, such as "172.50.0.0/16".

 .PARAMETER Action
 Use this parameter to define the action type of the item you're adding:

    ALLOW – Specifies items that will always take precedence over items with the DENY type.

    DENY – Specifies items to which traffic can be denied.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file.

 .EXAMPLE
 PS C:\Users\Administrator> Add-CloudLoadBalancerACLitem -CloudLBID 116351 -IP 5.5.5.5/32 -Action deny -account prod
 This example shows how to add an ACL item for the specified load balancer in the account prod.  This example shows how to explicitly block a single IP from being served by your load balancer, the IP being 5.5.5.5.

 .EXAMPLE
 PS C:\Users\Administrator> Add-CloudLoadBalancerACLitem -Account cloudus -CloudLBID 116351 -IP 5.5.5.5/32 -Action deny -RegionOverride DFW
 This example shows how to add an ACL item for the specified load balancer in the account for DFW

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Manage_Access_Lists-d1e3187.html

#>
}

function Remove-CloudLoadBalancerACLItem {

    Param(
        [Parameter (Position=0, Mandatory=$True)][string] $Account = $(throw "-Account required"),
        [Parameter(Position=1,Mandatory=$true)][string]$CloudLBID,
        [Parameter(Position=1,Mandatory=$true)][string]$ACLItemID,
        [Parameter (Position=2, Mandatory=$False)][string]$RegionOverride
    )


    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

        
    # Retrieving authentication token
    Get-AuthToken($account)
       

    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("loadbalancers")) + "/loadbalancers/$CloudLBID/accesslist/$ACLItemID"

    Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Method Delete -ErrorAction Stop

    Write-Host "The ACL item has been deleted."
    
<#
 .SYNOPSIS
 The Remove-CloudLoadBalancerACLItem cmdlet will remove a specific  ACL item from a cloud load balancer in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to define the ID of the load balancer you are modifying. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

  .PARAMETER ACLItemID
 Use this parameter to define the ID of the ACL item that you would like to remove. If you are unsure of this ID, please run the "Get-CloudLoadBalancerACLs" cmdlet.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file.

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudLoadBalancerACLItem -CloudLBID 116351 -ACLItemID 1234 -account prod
 This example shows how to remove an ACL item from the specified load balancer in the ORD region.

  .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancerACLItem cloudus -CloudLBID 116351 -RegionOverride DFW
 This example shows how to get a list of all available images for cloudus account in DFW region

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Manage_Access_Lists-d1e3187.html

#>
}

function Remove-CloudLoadBalancerACL {

    Param(
        [Parameter (Position=0, Mandatory=$True)][string] $Account = $(throw "-Account required"),
        [Parameter(Position=1,Mandatory=$true)][string]$CloudLBID,
        [Parameter (Position=2, Mandatory=$False)][string]$RegionOverride
        )


    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

        
    # Retrieving authentication token
    Get-AuthToken($account)
 
    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("loadbalancers")) + "/loadbalancers/$CloudLBID/accesslist"

          
    Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Method Delete -ErrorAction Stop

<#
 .SYNOPSIS
 The Remove-CloudLoadBalancerACL cmdlet will remove ALL ACL items from a cloud load balancer in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to define the ID of the load balancer you are modifying. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file.

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudLoadBalancerACLItem -CloudLBID 116351 -ACLItemID 1234 -account prod
 This example shows how to remove an ACL item from the specified load balancer in the account prod

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudLoadBalancerACLItem cloudus -CloudLBID 116351 -RegionOverride DFW
 This example shows how to get a list of all available images for cloudus account in DFW region


 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Manage_Access_Lists-d1e3187.html

#>
}

function Add-CloudLoadBalancerSessionPersistence {

    Param(
        [Parameter (Position=0, Mandatory=$True)][string] $Account = $(throw "-Account required"),
        [Parameter(Position=1,Mandatory=$true)][string]$CloudLBID,
        [Parameter(Position=2,Mandatory=$true)][string]$PersistenceType,
        [Parameter (Position=3, Mandatory=$False)][string]$RegionOverride
    )

     if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

        
    # Retrieving authentication token
    Get-AuthToken($account)
 
    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("loadbalancers")) + "/loadbalancers/$CloudLBID/sessionpersistence"
    

    $object = New-Object -TypeName PSCustomObject -Property @{
        "sessionPersistence"=New-Object -TypeName PSCustomObject -Property @{
            "persistenceType"=$PersistenceType.ToUpper()
            }
        }

    $JSONbody = $object | ConvertTo-Json -Depth 3
               
    # Making the call to the API
    $AddPersistence = Invoke-RestMethod -Uri $URI  -Headers $HeaderDictionary -ContentType application/json -Body $JSONBody -Method Put -ErrorAction Stop
      
     if (!$AddPersistence) {
            Write-host "Persistence not added"
            Break
        }
               
    Write-Host "Session Persistence has now been enabled"

        
<#
 .SYNOPSIS
 The Add-SessionPersistence cmdlet will enable session persistence on the specified load balancer.

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER CloudLBID
 Use this parameter to indicate the ID of the cloud load balancer of which you want to enable session persistence. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.
 
 .PARAMETER PeresistenceType
 Use this parameter to define the type of persistence you would like to enable on the specified load balancer.  The following modes of persistence are supported:

 HTTP_COOKIE - A session persistence mechanism that inserts an HTTP cookie and is used to determine the destination back-end node. This is supported for HTTP load balancing only.
 SOURCE_IP   - A session persistence mechanism that will keep track of the source IP address that is mapped and is able to determine the destination back-end node. This is supported for HTTPS pass-through and non-HTTP load balancing only.
 
 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file.

 .EXAMPLE
 PS C:\Users\Administrator> Add-SessionPersistence -CloudLBID 116351 -PersistenceType source_ip -account prod
 This example shows how to add source IP based session persistence to a cloud load balancer in the account prod.

.EXAMPLE
 PS C:\Users\Administrator> Add-SessionPersistence cloudus -CloudLBID 116351 -PersistenceType source_ip -RegionOverride DFW
 This example shows how to get a list of all available images for cloudus account in DFW region

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Manage_Session_Persistence-d1e3733.html

#>
}

function Update-CloudLoadBalancerSessionPersistence {

    Param(
        [Parameter (Position=0, Mandatory=$True)][string] $Account = $(throw "-Account required"),
        [Parameter(Position=1,Mandatory=$true)][string]$CloudLBID,
        [Parameter(Position=2,Mandatory=$true)][string]$PersistenceType,
        [Parameter (Position=3, Mandatory=$False)][string]$RegionOverride
    )

        if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
        }

        
        # Retrieving authentication token
        Get-AuthToken($account)
 
        # Setting variables needed to execute this function
        $URI = (Get-CloudURI("loadbalancers")) + "/loadbalancers/$CloudLBID/sessionpersistence"

        $object = New-Object -TypeName PSCustomObject -Property @{
        "sessionPersistence"=New-Object -TypeName PSCustomObject -Property @{
            "persistenceType"=$PersistenceType.ToUpper()
            }
        }

        $JSONbody = $object | ConvertTo-Json -Depth 3


        # Making the call to the API
        $AddPersistence = Invoke-RestMethod -Uri $URI  -Headers $HeaderDictionary -ContentType application/json -Body $JSONBody -Method Put -ErrorAction Stop
    

        if (!$AddPersistencet) {
            Write-host "Persistence not added"
            Break
        }
     
        Write-Host "Session Persistence has now been modified"

        
<#
 .SYNOPSIS
 The Update-SessionPersistence cmdlet will modify session persistence on the specified load balancer.

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER CloudLBID
 Use this parameter to indicate the ID of the cloud load balancer of which you want to update session persistence settings. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.
 
 .PARAMETER PeresistenceType
 Use this parameter to define the type of persistence you would like to enable on the specified load balancer.  The following modes of persistence are supported:

 HTTP_COOKIE - A session persistence mechanism that inserts an HTTP cookie and is used to determine the destination back-end node. This is supported for HTTP load balancing only.
 SOURCE_IP   - A session persistence mechanism that will keep track of the source IP address that is mapped and is able to determine the destination back-end node. This is supported for HTTPS pass-through and non-HTTP load balancing only.
 
  .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file.

 .EXAMPLE
 PS C:\Users\Administrator> Update-SessionPersistence -CloudLBID 116351 -PersistenceType source_ip -Region ord
 This example shows how to update the session persistence type to "SOURCE_IP" of a cloud load balancer in the ORD region.

 .EXAMPLE
 PS C:\Users\Administrator> Update-SessionPersistence cloudus -CloudLBID 116351 -PersistenceType source_ip -RegionOverride DFW
 This example shows how to get a list of all available images for cloudus account in DFW region

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Manage_Session_Persistence-d1e3733.html

#>
}

function Remove-CloudLoadBalancerSessionPersistence {

    Param(
        [Parameter (Position=0, Mandatory=$True)][string] $Account = $(throw "-Account required"),
        [Parameter(Position=1,Mandatory=$true)][string]$CloudLBID,
        [Parameter (Position=3, Mandatory=$False)][string]$RegionOverride
    )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
        }

        
    # Retrieving authentication token
    Get-AuthToken($account)
 
    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("loadbalancers")) + "/loadbalancers/$CloudLBID/sessionpersistence"
    

    # Making the call to the API
    Invoke-RestMethod -Uri $URI  -Headers $HeaderDictionary -Method Delete -ErrorAction Stop
               
    Write-Host "Session Persistence has now been disabled."

        
<#
 .SYNOPSIS
 The Remove-CloudLoadBalancerSessionPersistence cmdlet will disable session persistence on the specified load balancer.

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER CloudLBID
 Use this parameter to indicate the ID of the cloud load balancer from which you want to disable session persistence. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.
 
 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file.

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudLoadBalancerSessionPersistence -CloudLBID 116351 -account prod
 This example shows how to disable based session persistence on a cloud load balancer in the prod account.

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudLoadBalancerSessionPersistence cloudus -CloudLBID 116351 -RegionOverride DFW
 This example shows how to get a list of all available images for cloudus account in DFW region

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Manage_Session_Persistence-d1e3733.html

#>
}

function Add-CloudLoadBalancerConnectionLogging {

    Param(
        [Parameter (Position=0, Mandatory=$True)][string] $Account = $(throw "-Account required"),
        [Parameter(Position=1,Mandatory=$true)][string]$CloudLBID,
        [Parameter (Position=2, Mandatory=$False)][string]$RegionOverride
    )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
        }

        
    # Retrieving authentication token
    Get-AuthToken($account)
 
    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("loadbalancers")) + "/loadbalancers/$CloudLBID/connectionlogging"

    $object = New-Object -TypeName PSCustomObject -Property @{
        "connectionLogging"=New-Object -TypeName PSCustomObject -Property @{
            "enabled"="true"
            }
        }
        
 
    $JSONbody = $object | ConvertTo-Json
    
    Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $JSONBody -ContentType application/json -Method Put -ErrorAction Stop

    Write-Host "Connection logging has now been enabled."

    

<#
 .SYNOPSIS
 The Add-CloudLoadBalancerConnectionLogging cmdlet will enable connection logging on a cloud load balancer in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to define the ID of the load balancer you are about to modify. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file.

 .EXAMPLE
 PS C:\Users\Administrator> Add-CloudLoadBalancerConnectionLogging -CloudLBID 116351 -account prod
 This example shows how to enable connection logging on a CLB in the account prod.

 .EXAMPLE
 PS C:\Users\Administrator> Add-CloudLoadBalancerConnectionLogging cloudus -CloudLBID 116351 -RegionOverride DFW
 This example shows how to add connection logging for the cloudus account in DFW region


 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Log_Connections-d1e3924.html

#>
}

function Remove-CloudLoadBalancerConnectionLogging {

    Param(
        [Parameter (Position=0, Mandatory=$True)][string] $Account = $(throw "-Account required"),
        [Parameter(Position=1,Mandatory=$true)][string]$CloudLBID,
        [Parameter (Position=2, Mandatory=$False)][string]$RegionOverride
    )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
        }

        
    # Retrieving authentication token
    Get-AuthToken($account)
 
    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("loadbalancers")) + "/loadbalancers/$CloudLBID/connectionlogging"

    $object = New-Object -TypeName PSCustomObject -Property @{
        "connectionLogging"=New-Object -TypeName PSCustomObject -Property @{
            "enabled"="false"
            }
        }        
 
    $JSONbody = $object | ConvertTo-Json

    Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $JSONBody -ContentType application/json -Method Put -ErrorAction Stop

    Write-Host "Connection logging has now been disabled."


<#
 .SYNOPSIS
 The Remove-CloudLoadBalancerConnectionLogging cmdlet will disable connection logging on a cloud load balancer in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to define the ID of the load balancer you are about to modify. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file.

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudLoadBalancerConnectionLogging -CloudLBID 116351 -account prod
 This example shows how to disable connection logging on a CLB in the account prod.

 .EXAMPLE
 PS C:\Users\Administrator> Add-CloudLoadBalancerConnectionLogging cloudus -CloudLBID 116351 -RegionOverride DFW
 This example shows how to remove connection logging for the cloudus account in DFW region

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Log_Connections-d1e3924.html

#>
}

function Add-CloudLoadBalancerConnectionThrottling {

    Param(
        [Parameter (Position=0, Mandatory=$True)][string] $Account = $(throw "-Account required"),
        [Parameter(Position=1,Mandatory=$true)][string]$CloudLBID,
        [Parameter(Position=2,Mandatory=$true)][int]$MaxConnectionRate,
        [Parameter(Position=3,Mandatory=$true)][int]$MaxConnections,
        [Parameter(Position=4,Mandatory=$true)][int]$MinConnections,
        [Parameter(Position=5,Mandatory=$true)][int]$RateInterval,
        [Parameter (Position=6, Mandatory=$False)][string]$RegionOverride
    )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
        }

        
    # Retrieving authentication token
    Get-AuthToken($account)
 
    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("loadbalancers")) + "/loadbalancers/$CloudLBID/connectionthrottle"

    $object = New-Object -TypeName PSCustomObject -Property @{
        "connectionThrottle"=New-Object -TypeName PSCustomObject -Property @{
            "minConnections"=$MinConnections;
            "maxConnections"=$MaxConnections;
            "maxConnectionRate"=$MaxConnectionRate;
            "rateInterval"=$RateInterval
            }
        }        
 
    $JSONbody = $object | ConvertTo-Json
        
    Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $JSONBody -ContentType application/json -Method Put -ErrorAction Stop

    Write-Host "Connection throttling has now been enabled."

        
<#
 .SYNOPSIS
 The Add-CloudLoadBalancerConnectionThrottling cmdlet will enable connection throttling on a cloud load balancer in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to define the ID of the load balancer you are about to modify. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

 .PARAMETER MaxConnectionRate
 Use this parameter to define the maximum number of connections allowed from a single IP address in the defined "RateInterval" parameter. Setting a value of 0 allows an unlimited connection rate; otherwise, set a value between 1 and 100000.

 .PARAMETER MaxConnections
 Use this parameter to define the maximum number of connections to allow for a single IP address. Setting a value of 0 will allow unlimited simultaneous connections; otherwise set a value between 1 and 100000.

 .PARAMETER MinConnections
 Use this parameter to define the lowest possible number of connections per IP address before applying throttling restrictions. Setting a value of 0 allows unlimited simultaneous connections; otherwise, set a value between 1 and 1000.

 .PARAMETER RateInterval
 Use this parameter to define the frequency (in seconds) at which the "maxConnectionRate" parameter is assessed. For example, a "maxConnectionRate" value of 30 with a "rateInterval" of 60 would allow a maximum of 30 connections per minute for a single IP address. This value must be between 1 and 3600.

  .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file.

 .EXAMPLE
 PS C:\Users\Administrator> Add-CloudLoadBalancerConnectionThrottling -CloudLBID 116351 -account prod
 This example shows how to enable connection logging on a CLB in the account prod.

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Throttle_Connections-d1e4057.html

#>
}

function Update-CloudLoadBalancerConnectionThrottling {

    Param(
        [Parameter (Position=0, Mandatory=$True)][string] $Account = $(throw "-Account required"),
        [Parameter(Position=1,Mandatory=$true)][string]$CloudLBID,
        [Parameter(Position=2,Mandatory=$true)][int]$MaxConnectionRate,
        [Parameter(Position=3,Mandatory=$true)][int]$MaxConnections,
        [Parameter(Position=4,Mandatory=$false)][int]$MinConnections,
        [Parameter(Position=5,Mandatory=$true)][int]$RateInterval,
        [Parameter (Position=6, Mandatory=$False)][string]$RegionOverride
    )


    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
        }

        
    # Retrieving authentication token
    Get-AuthToken($account)
 
    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("loadbalancers")) + "/loadbalancers/$CloudLBID/connectionthrottle"

    $object = New-Object -TypeName PSCustomObject -Property @{
        "connectionThrottle"=New-Object -TypeName PSCustomObject -Property @{
            "minConnections"=$MinConnections;
            "maxConnections"=$MaxConnections;
            "maxConnectionRate"=$MaxConnectionRate;
            "rateInterval"=$RateInterval
            }
        }        
 
    $JSONbody = $object | ConvertTo-Json

    Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -ContentType application/json -Body $JSONBody -Method Put -ErrorAction Stop

    Write-Host "Connection Throttling values have now been modified."

    
<#
 .SYNOPSIS
 The Update-CloudLoadBalancerConnectionThrottling cmdlet will modify connection throttling values on the specified load balancer.

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER CloudLBID
 Use this parameter to indicate the ID of the cloud load balancer. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.
 
 .PARAMETER $ChangeMaxConnectionRate
 Use this switch to indicate you wish to change the MaxConnectionRate value.

 .PARAMETER $ChangeMaxConnections
 Use this switch to indicate you wish to change the MaxConnections value.

 .PARAMETER $ChangeMinConnections
 Use this switch to indicate you wish to change the MinConnections value.

 .PARAMETER $ChangeRateInterval
 Use this switch to indicate you wish to change the RateInterval value.

 .PARAMETER MaxConnectionRate
 Use this parameter to define the maximum number of connections allowed from a single IP address in the defined "RateInterval" parameter. Setting a value of 0 allows an unlimited connection rate; otherwise, set a value between 1 and 100000.

 .PARAMETER MaxConnections
 Use this parameter to define the maximum number of connections to allow for a single IP address. Setting a value of 0 will allow unlimited simultaneous connections; otherwise set a value between 1 and 100000.

 .PARAMETER MinConnections
 Use this parameter to define the lowest possible number of connections per IP address before applying throttling restrictions. Setting a value of 0 allows unlimited simultaneous connections; otherwise, set a value between 1 and 1000.

 .PARAMETER RateInterval
 Use this parameter to define the frequency (in seconds) at which the "maxConnectionRate" parameter is assessed. For example, a "maxConnectionRate" value of 30 with a "rateInterval" of 60 would allow a maximum of 30 connections per minute for a single IP address. This value must be between 1 and 3600.
 
  .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file.

 .EXAMPLE
 PS C:\Users\Administrator> Update-CloudLoadBalancerConnectionThrottling -CloudLBID 116351 -MaxConnectionRate 10 -MaxConnections 100 -MinConnections 5 -RateInterval 1 -account prod
  
 This example shows how to update the connection throttling values of a CLB in the account prod

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Throttle_Connections-d1e4057.html

#>
}

function Remove-CloudLoadBalancerConnectionThrottling {

    Param(
        [Parameter (Position=0, Mandatory=$True)][string] $Account = $(throw "-Account required"),
        [Parameter(Position=1,Mandatory=$true)][string]$CloudLBID,
        [Parameter (Position=2, Mandatory=$False)][string]$RegionOverride
    )


    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
        }

        
    # Retrieving authentication token
    Get-AuthToken($account)
 
    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("loadbalancers")) + "/loadbalancers/$CloudLBID/connectionthrottle"    

    Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $JSOBody -Method Delete -ErrorAction Stop

    Write-Host "Connection throttling has now been disabled."


<#
 .SYNOPSIS
 The Remove-ConnectionThrottling cmdlet will disable connection logging on a cloud load balancer in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to define the ID of the load balancer you are about to modify. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

  .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file.

 .EXAMPLE
 PS C:\Users\Administrator> Remove-ConnectionThrottling -CloudLBID 116351 -account prod
  This example shows how to disable connection throttling on a CLB in the account prod.

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Throttle_Connections-d1e4057.html

#>
}

function Get-CloudLoadBalancerHealthMonitor {

    Param(
        [Parameter (Position=0, Mandatory=$True)][string] $Account = $(throw "-Account required"),
        [Parameter(Position=1,Mandatory=$true)][string]$CloudLBID,
        [Parameter (Position=2, Mandatory=$False)][string]$RegionOverride
    )


    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

        
    # Retrieving authentication token
    Get-AuthToken($account)
       

    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("loadbalancers")) + "/loadbalancers/$CloudLBID/healthmonitor"
   
    $HealthMonitor = Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Method Get -ErrorAction Stop

    if (!$HealthMonitor.healthMonitor.delay) {
        Write-Host "This load balancer does not currently have any health monitors configured." -ForegroundColor Red
        break;
    }
   
    $HealthMonitor.healthMonitor | ft -AutoSize
    

<#
 .SYNOPSIS
 The Get-CloudLoadBalancerHealthMonitor cmdlet will return the status of health monitoring on a cloud load balancer in the specified Account.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to define the ID of the load balancer you are about to query. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against.  Valid choices are defined in Conf.xml

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancerHealthMonitor -CloudLBID 9956 -Account prod
 This example shows how to get the status and configuration of a cloud load balancer in the account prod

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancerHealthMonitor cloudus -CloudLBID 12345 -RegionOverride DFW
 This example shows how to get a list of all available images for cloudus account in DFW region

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Monitor_Health-d1e3434.html

#>
}

function Add-CloudLoadBalancerHealthMonitor {

    Param(
        [Parameter (Position=0, Mandatory=$True)][string] $Account = $(throw "-Account required"),
        [Parameter(Position=1,Mandatory=$true)][string]$CloudLBID,
        [Parameter(Position=2,Mandatory=$true)][string][ValidateSet("CONNECT","HTTP","HTTPS")]$type,
        [Parameter(Position=5,Mandatory=$true)][int]$MonitorDelay,
        [Parameter(Position=6,Mandatory=$true)][int]$MonitorTimeout,
        [Parameter(Position=7,Mandatory=$true)][int]$MonitorFailureAttempts,
        [Parameter(Position=8,Mandatory=$false)][string]$MonitorBodyRegex,
        [Parameter(Position=9,Mandatory=$false)][string]$MonitorStatusRegex,
        [Parameter(Position=10,Mandatory=$false)][string]$MonitorHTTPPath,
        [Parameter(Position=11,Mandatory=$false)][string]$MonitorHostHeader,
        [Parameter (Position=12, Mandatory=$False)][string]$RegionOverride
    )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
        }

        
    # Retrieving authentication token
    Get-AuthToken($account)
 
    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("loadbalancers")) + "/loadbalancers/$CloudLBID/healthmonitor"


    if ($type -eq "CONNECT"){
        $object = New-Object -TypeName PSCustomObject -Property @{
                "healthMonitor"=New-Object -TypeName PSCustomObject -Property @{
                    "type"=$type;
                    "delay"=$MonitorDelay;
                    "timeout"=$MonitorTimeout;
                    "attemptsBeforeDeactivation"=$MonitorFailureAttempts
                }
            }
    }

    else {
        $object = New-Object -TypeName PSCustomObject -Property @{
                "healthMonitor"=New-Object -TypeName PSCustomObject -Property @{
                    "type"=$type;
                    "delay"=$MonitorDelay;
                    "timeout"=$MonitorTimeout;
                    "attemptsBeforeDeactivation"=$MonitorFailureAttempts;
                    "path"=$MonitorHTTPPath;
                    "statusRegex"=$MonitorStatusRegex;
                    "bodyRegex"=$MonitorBodyRegex;
                    "hostHeader"=$MonitorHostHeader
                    }
                }
            }
    
    $JSONbody = $object | ConvertTo-Json -Depth 3
    
    Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $JSONBody -ContentType application/json -Method Put -ErrorAction Stop

    Write-Host "Health Monitoring has now been enabled."

    
  <#
 .SYNOPSIS
 The Add-HealthMonitor cmdlet will enable health monitoring on a cloud load balancer in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to define the ID of the load balancer you are about to modify. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

 .PARAMETER Type
 Use this parameter to define type of monitor. Options are
 
    CONNECT    - Connected to each node on defined to port to ensure service is listening
    HTTP/HTTPS - These are more intelligent than CONNECT and are capable of processing HTTP/HTTPS repsonses to determine node condition

 .PARAMETER MonitorDelay
 Use this parameter to define the minimum number of seconds to wait before executing the health monitor. Must be a number between 1 and 3600. This parameter is needed for any type of health check.

 .PARAMETER MonitorTimeout
 Use this parameter to define the maximum number of seconds to wait for a connection to be established before timing out. Must be a number between 1 and 300. This parameter is needed for any type of health check.

 .PARAMETER MonitorFailureAttempts
 Use this parameter to define the number of permissible monitor failures before removing a node from rotation. Must be a number between 1 and 10. This parameter is needed for any type of health check.

 .PARAMETER MonitorBodyRegex
 Use this parameter to define a regular expression that will be used to evaluate the contents of the body of the HTTP/HTTPS response.

 .PARAMETER MonitorStatusRegEx
 Use this parameter to define a regular expression that will be used to evaluate the HTTP status code returned in the HTTP/HTTPS response.

 .PARAMETER MointorHTTPPath
 Use this parameter to define the HTTP path that will be used in the sample request.

 .PARAMETER MonitorHostHeader        
 Use this parameter to define the name of a host for which the health monitors will check. This parameter is only needed for an HTTP/HTTPS type monitor.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file.

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Monitor_Connections-d1e3536.html

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Monitor_HTTP_and_HTTPS-d1e3635.html

#>
}

function Remove-CloudLoadBalancerHealthMonitor {

    Param(
        [Parameter (Position=0, Mandatory=$True)][string] $Account = $(throw "-Account required"),
        [Parameter(Position=1,Mandatory=$true)][string]$CloudLBID,
        [Parameter (Position=2, Mandatory=$False)][string]$RegionOverride
    )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

        
    # Retrieving authentication token
    Get-AuthToken($account)
       

    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("loadbalancers")) + "/loadbalancers/$CloudLBID/healthmonitor"
    
    $HealthMonitor = Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Method Delete -ErrorAction Stop

    if (!$HealthMonitor.healthMonitor.delay) {
        Write-Host "This load balancer does not currently have any health monitors configured." -ForegroundColor Red
        break;
    }

    Write-Host "Health monitoring has been removed from this load balancer."
    

<#
 .SYNOPSIS
 The Remove-CloudLoadBalancerHealthMonitor cmdlet will remove a health monitor from a cloud load balancer in the specified region. 

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to define the ID of the load balancer you are about to modify. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against.  Valid choices are defined in Conf.xml

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancerHealthMonitor -CloudLBID 9956 -Account prod
 This example shows how to get the status and configuration of a cloud load balancer in the account prod.

  .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudLoadBalancerHealthMonitor cloudus -CloudLBID 12345 -RegionOverride DFW
 This example shows how to get a list of all available images for cloudus account in DFW region

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Monitor_Health-d1e3434.html

#>
}

function Add-CloudLoadBalancerContentCaching {

    Param(
        [Parameter (Position=0, Mandatory=$True)][string] $Account = $(throw "-Account required"),
        [Parameter(Position=1,Mandatory=$true)][string]$CloudLBID,
        [Parameter (Position=2, Mandatory=$False)][string]$RegionOverride
    )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

        
    # Retrieving authentication token
    Get-AuthToken($account)
       

    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("loadbalancers")) + "/loadbalancers/$CloudLBID/contentcaching"
    

    $object = New-Object -TypeName PSCustomObject -Property @{
            "contentCaching"=New-Object -TypeName PSCustomObject -Property @{
                "enabled"="true";
                }
            }
   
   $JSONbody = $object | ConvertTo-Json -Depth 3
 
   $ContentCaching = Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $JSONBody -ContentType application/json -Method Put -ErrorAction Stop

   Write-Host "Content caching has been enabled on this load balancer."
   
<#
 .SYNOPSIS
 The Add-CloudLoadBalancerContentCaching cmdlet will enable content caching for a cloud load balancer in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to define the ID of the load balancer you are about to modify. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file.

 .EXAMPLE
 PS C:\Users\Administrator> Add-CloudLoadBalancerContentCaching -CloudLBID 9956 -Region ord
 This example shows how to enable content caching for a cloud load balancer in the ORD region.

 .EXAMPLE
 PS C:\Users\Administrator> Add-CloudLoadBalancerContentCaching cloudus -CloudLBID 12345 -RegionOverride DFW
 This example shows how to get a list of all available images for cloudus account in DFW region


 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/ContentCaching-d1e3358.html

#>
}

function Remove-CloudLoadBalancerContentCaching {

    Param(
        [Parameter (Position=0, Mandatory=$True)][string] $Account = $(throw "-Account required"),
        [Parameter(Position=1,Mandatory=$true)][string]$CloudLBID,
        [Parameter (Position=2, Mandatory=$False)][string]$RegionOverride
    )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

        
    # Retrieving authentication token
    Get-AuthToken($account)
       

    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("loadbalancers")) + "/loadbalancers/$CloudLBID/contentcaching"


    $object = New-Object -TypeName PSCustomObject -Property @{
            "contentCaching"=New-Object -TypeName PSCustomObject -Property @{
                "enabled"="false";
                }
            }
   
   $JSONbody = $object | ConvertTo-Json -Depth 3
 
   $ContentCaching = Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $JSONBody -ContentType application/json -Method Put -ErrorAction Stop

   Write-Host "Content caching has been removed from this load balancer."
    
<#
 .SYNOPSIS
 The Remove-CloudLoadBalancerContentCaching cmdlet will remove content caching from a cloud load balancer in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to define the ID of the load balancer you are about to modify. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file.

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudLoadBalancerContentCaching -CloudLBID 9956 -account prod
 This example shows how to remove content caching from a cloud load balancer in the account prod.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancerNodeEvents cloudus -CloudLBID 12345 -RegionOverride DFW
 This example shows how to get a list of all available images for cloudus account in DFW region

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/ContentCaching-d1e3358.html

#>
}

function Get-CloudLoadBalancerSSLTermination {

    Param(
        [Parameter (Position=0, Mandatory=$True)][string] $Account = $(throw "-Account required"),
        [Parameter(Position=1,Mandatory=$true)][string]$CloudLBID,
        [Parameter (Position=2, Mandatory=$False)][string]$RegionOverride
    )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

        
    # Retrieving authentication token
    Get-AuthToken($account)  

    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("loadbalancers")) + "/loadbalancers/$CloudLBID/ssltermination"

    $SSLTermination = Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Method Get -ErrorAction Stop

    if (!$SSLTermination) {
        Write-Host "`nNo SSL termination configured on load balancer" -ForegroundColor Red
        break;
    }
    
    $SSLTermination.sslTermination
  
<#
 .SYNOPSIS
 The Get-CloudLoadBalancerSSLTermination cmdlet will retrieve the SSL termination settings from a cloud load balancer in the specified account.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to define the ID of the load balancer you are about to query. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancerSSLTermination -CloudLBID 555 -Account prod
 This example shows how to retrieve the SSL termination settings from a cloud load balancer in the prod account.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancerSSLTermination cloudus -CloudLBID 12345 -RegionOverride DFW
 This example shows how to get a list of all available images for cloudus account in DFW region

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/SSLTermination-d1e2479.html

#>
}

function Add-CloudLoadBalancerSSLTermination {

    Param(
        [Parameter (Position=0, Mandatory=$True)][string] $Account = $(throw "-Account required"),
        [Parameter(Position=1,Mandatory=$true)][string]$CloudLBID,
        [Parameter(Position=2,Mandatory=$true)][int]$SSLPort,
        [Parameter(Position=3,Mandatory=$true)][string]$PrivateKey,
        [Parameter(Position=4,Mandatory=$true)][string]$Certificate,
        [Parameter(Position=5,Mandatory=$false)][string]$IntermediateCertificate,
        [Parameter(Position=6,Mandatory=$false)][switch]$Enabled,
        [Parameter(Position=7,Mandatory=$false)][switch]$SecureTrafficOnly,
        [Parameter (Position=8, Mandatory=$False)][string]$RegionOverride
    )

    
    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

        
    # Retrieving authentication token
    Get-AuthToken($account)  

    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("loadbalancers")) + "/loadbalancers/$CloudLBID/ssltermination"


    if (($enabled) -and ($SecureTrafficOnly)) {
        
        $object = New-Object -TypeName PSCustomObject -Property @{
            "sslTermination"=New-Object -TypeName PSCustomObject -Property @{
                "enabled"="true";
                "securePort"=$SSLPort;
                "secureTrafficOnly"="true";
                "privatekey"=$PrivateKey;
                "certificate"=$Certificate;
                "intermediateCertificate"=$IntermediateCertificate
                }
            }
        }
        
    elseif (($enabled) -and (!$SecureTrafficOnly)) {

     $object = New-Object -TypeName PSCustomObject -Property @{
            "sslTermination"=New-Object -TypeName PSCustomObject -Property @{
                "enabled"="true";
                "securePort"=$SSLPort;
                "secureTrafficOnly"="false";
                "privatekey"=$PrivateKey;
                "certificate"=$Certificate;
                "intermediateCertificate"=$IntermediateCertificate
                }
            }
        }
        
    elseif ((!$enabled) -and ($SecureTrafficOnly)) {
        
         $object = New-Object -TypeName PSCustomObject -Property @{
            "sslTermination"=New-Object -TypeName PSCustomObject -Property @{
                "enabled"="false";
                "securePort"=$SSLPort;
                "secureTrafficOnly"="true";
                "privatekey"=$PrivateKey;
                "certificate"=$Certificate;
                "intermediateCertificate"=$IntermediateCertificate
                }
            }
        }
        

    elseif ((!$enabled) -and (!$SecureTrafficOnly)) {
        
         $object = New-Object -TypeName PSCustomObject -Property @{
            "sslTermination"=New-Object -TypeName PSCustomObject -Property @{
                "enabled"="false";
                "securePort"=$SSLPort;
                "secureTrafficOnly"="false";
                "privatekey"=$PrivateKey;
                "certificate"=$Certificate;
                "intermediateCertificate"=$IntermediateCertificate
                }
            }
        }
    
    $JSONbody = $object | ConvertTo-Json -Depth 3
   
    Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $JSONBody -ContentType application/json -Method Put -ErrorAction Stop | Out-Null
        
    Write-Host "SSL termination has been configured."
        

<#
 .SYNOPSIS
 The Add-CloudLoadBalancerSSLTermination cmdlet will add SSL termination to a cloud load balancer in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to define the ID of the load balancer you are about to modify. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

 .PARAMETER SSLPort
 Use this parameter to define the port on which the SSL termination load balancer will listen for secure traffic. The SSLPort must be unique to the existing LB protocol/port combination. For example, port 443.

 .PARAMETER PrivateKey
 Use this parameter to define the private key for the SSL certificate. The private key is validated and verified against the provided certificate(s).

 .PARAMETER Certificate
 Use this parameter to define the certificate used for SSL termination. The certificate is validated and verified against the key and intermediate certificate if provided.

 .PARAMETER IntermediateCertificate
 Use this parameter to define the user's intermediate certificate used for SSL termination. The intermediate certificate is validated and verified against the key and certificate credentials provided.

 .PARAMETER Enabled
 Use this switch to indicate if the load balancer is enabled to terminate SSL traffic. If the Enabled switch is not passed, the load balancer will retain its specified SSL attributes, but will NOT immediately terminate SSL traffic upon configuration.

 .PARAMETER SecureTrafficOnly
 Use this switch to indicate if the load balancer may accept only secure traffic. If the SecureTrafficOnly switch is passed, the load balancer will NOT accept non-secure traffic. 

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file.

 .EXAMPLE
 PS C:\Users\Administrator> Add-CloudLoadBalancerSSLTermination -CloudLBID 116351 -SSLPort 443 -PrivateKey "PrivateKeyGoesHereInQuotes" -Certificate "CertificateGoesHereInQuotes" -Enabled -account prod
  This example shows how to add SSL termination to a cloud load balancer in the ORD region.

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/SSLTermination-d1e2479.html

#>
}

function Update-CloudLoadBalancerSSLTermination {

    Param(
        [Parameter (Position=0, Mandatory=$True)][string] $Account = $(throw "-Account required"),
        [Parameter(Position=1,Mandatory=$true)][string]$CloudLBID,
        [Parameter(Position=2,Mandatory=$false)][switch]$EnableSSLTermination,
        [Parameter(Position=3,Mandatory=$false)][switch]$DisableSSLTermination,
        [Parameter(Position=4,Mandatory=$false)][int]$UpdateSSLPort,
        [Parameter(Position=5,Mandatory=$false)][switch]$EnableSecureTrafficOnly,
        [Parameter(Position=6,Mandatory=$false)][switch]$DisableSecureTraficOnly,
        [Parameter (Position=7, Mandatory=$False)][string]$RegionOverride
        
        )
    

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

        
    # Retrieving authentication token
    Get-AuthToken($account)  

    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("loadbalancers")) + "/loadbalancers/$CloudLBID/ssltermination"
     
    $sslTerm = New-Object -TypeName PSCustomObject -Property @{}
        
     
    if ($EnableSSLTermination) {$sslTerm | Add-Member -MemberType NoteProperty -Name "enabled" -Value "true"
        }
        

    if ($DisableSSLTermination) {$sslTerm | Add-Member -MemberType NoteProperty -Name "enabled" -Value "false"
        }

    if ($EnableSecureTrafficOnly) {$sslTerm | Add-Member -MemberType NoteProperty -Name "secureTrafficOnly" -Value "true"
        }

    if ($DisableSecureTraficOnly) {$sslTerm | Add-Member -MemberType NoteProperty -Name "secureTrafficOnly" -Value "false"
        }

    if ($UpdateSSLPort) {$sslTerm | Add-Member -MemberType NoteProperty -Name "securePort" -Value $UpdateSSLPort
        }

    $object = New-Object -TypeName PSCustomObject -Property @{
        "sslTermination" = $sslTerm
        }
   
           
    JSONbody = $object | ConvertTo-Json -Depth 3

    Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $JSONBody -ContentType application/json -Method Put -ErrorAction Stop | Out-Null
        
    Write-Host "SSL termination configuration has been updated."

    
<#
 .SYNOPSIS
 The Update-CloudLoadBalancerSSLTermination cmdlet will add SSL termination to a cloud load balancer in the specified region.

 .DESCRIPTION
 Using this cmdlet, you can alter the port in which you would like to accept secure traffic, whether or not you would like the load balancer to be SSL ONLY, and whether or not SSL termination is active or simply configured and standing by.

 .PARAMETER CloudLBID
 Use this parameter to define the ID of the load balancer you are about to modify. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

 .PARAMETER UpdateSSLPort
 Use this switch to indicate that you would like to update the port which your load balancer will be accepting secure traffic on. Define the new port with the SSLPort parameter.
  
 .PARAMETER EnableSSLTermination
 Use this switch to indicate that SSL termination can be enabled on the specified load balancer. If this switch is passed, the load balancer will enact its configuration for SSL termination.

 .PARAMETER DisableSSLTermination
 Use this switch to indicate that SSL termination can be disabled on the specified load balancer. If this switch is passed, the load balancer will retain its configuration for SSL termination, however, it will not terminate SSL connections again until you re-enable it.

 .PARAMETER EnableSecureTrafficOnly
 Use this switch to indicate if the load balancer may accept only secure traffic. If this switch is passed, the load balancer will begin ONLY accepting secure traffic.  All non-secure traffic will be rejected.

 .PARAMETER DisableSecureTrafficOnly
 Use this switch to indicate if the load balancer may accept non-secure and secure traffic. If this switch is passed, the load balancer will begin accepting all types of traffic.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file.

 .EXAMPLE
 PS C:\Users\Administrator> Update-CloudLoadBalancerSSLTermination -CloudLBID 116351 -DisableSSLTrafficOnly -account prod
 This example shows how to update the SSL termination settings of a cloud load balancer in the account prod region. This example would configure the load balancer to accept both non-secure and secure traffic.

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/SSLTermination-d1e2479.html

#>
}

function Remove-CloudLoadBalancerSSLTermination {

    Param(
        [Parameter (Position=0, Mandatory=$True)][string] $Account = $(throw "-Account required"),
        [Parameter(Position=1,Mandatory=$true)][string]$CloudLBID,
        [Parameter (Position=2, Mandatory=$False)][string]$RegionOverride
    )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }
            
    # Retrieving authentication token
    Get-AuthToken($account)  

    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("loadbalancers")) + "/loadbalancers/$CloudLBID/ssltermination"
    
    $SSLTermination = Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Method Delete -ErrorAction Stop
              
    Write-Host "All SSL settings have been removed."
    
<#
 .SYNOPSIS
 The Remove-CloudLoadBalancerSSLTermination cmdlet will remove all SSL termination settings from a cloud load balancer in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to define the ID of the load balancer you are about to modify. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file.

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudLoadBalancerSSLTermination -CloudLBID 555 -account prod
 This example shows how to remove the SSL termination settings from a cloud load balancer in the account prod.

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudLoadBalancerSSLTermination cloudus -CloudLBID 12345 -RegionOverride DFW
 This example shows how to get a list of all available images for cloudus account in DFW region

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/SSLTermination-d1e2479.html

#>
}
