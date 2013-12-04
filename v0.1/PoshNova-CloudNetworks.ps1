<############################################################################################

                           ___          _         __                
                          / _ \___  ___| |__   /\ \ \_____   ____ _ 
                         / /_)/ _ \/ __| '_ \ /  \/ / _ \ \ / / _` |
                        / ___/ (_) \__ \ | | / /\  / (_) \ V / (_| |
                        \/    \___/|___/_| |_\_\ \/ \___/ \_/ \__,_|
                                                      Cloud Networks

Authors
-----------
    Nielsen Pierce (nielsen.pierce@rackspace.co.uk)
    Alexei Andreyev (alexei.andreyev@rackspace.co.uk)
    
Description
-----------
PowerShell v3 module for interaction with NextGen Rackspace Cloud API (PoshNova) 

Networks v2.0 API reference
---------------------------
http://docs.rackspace.com/networks/api/v2/cn-devguide/content/ch_preface.html

############################################################################################>



function Get-CloudNetworks{

    Param(
        [Parameter(Position=0, Mandatory=$True)][string] $Account = $(throw "Please specify required Cloud Account with -account parameter"),
        [Parameter (Position=1, Mandatory=$False)][string]$RegionOverride
    )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

    Get-AuthToken($account)

    $URI = (Get-CloudURI("servers")) + "/os-networksv2.xml"
    
    # Making the call to the API for a list of available networks and storing data into a variable
    [xml]$NetworkList = (Invoke-RestMethod -Uri $URI  -Headers $HeaderDictionary).innerxml
    
    # Since the response body is XML, we can use dot notation to show the information needed without further parsing.
    $NetworkList.networks.network

<#
 .SYNOPSIS
 The Get-CloudNetworks cmdlet will pull down a list of all Rackspace Cloud Networks on your account.

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file. 
 Please note that this switch is not supported for UK Cloud accounts

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudNetworks -Account prod
 This example shows how to get a list of all networks currently deployed in the account prod

 .LINK
 http://docs.rackspace.com/servers/api/v2/cn-devguide/content/list_networks.html
#>
}

function Add-CloudNetwork {
    
    Param(
        [Parameter(Position=0, Mandatory=$True)][string] $CloudNetworkLabel = $(throw "Please provide netowrk label with -CloudNetworkLabel parameter"),
        [Parameter(Position=1, Mandatory=$true)][string] $CloudNetworkCIDR = $(throw "Please provide netowrk CIDR with -CloudNetworkCIDR parameter"),
        [Parameter(Position=2, Mandatory=$True)][string] $Account = $(throw "Please specify required Cloud Account with -account parameter"),
        [Parameter(Position=3, Mandatory=$False)][string]$RegionOverride
    )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

   try {
        # Retrieving authentication token
        Get-AuthToken($Account)

        # Setting variables needed to execute this function
        $NewNetURI = (Get-CloudURI("servers")) + "/os-networksv2.xml"

        [xml]$NewCloudNetXMLBody = '<?xml version="1.0" encoding="UTF-8"?>
            <network
                cidr="'+$CloudNetworkCIDR+'"
                label="'+$CloudNetworkLabel+'"
            />'
        
        
        $NewCloudNet = Invoke-RestMethod -Uri $NewNetURI -Headers $HeaderDictionary -Body $NewCloudNetXMLBody -ContentType application/xml -Method Post -ErrorAction Stop

        return $NewCloudNet.network
    }
    catch {
        Invoke-Exception($error)
    }

<#
 .SYNOPSIS
 The Add-CloudNetwork cmdlet will create a new private cloud network in the region specified in the PoshNova configuration file.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudNetworkLabel
 Use this parameter to define the label of the cloud network you wish to create.

 .PARAMETER CloudNetworkCIDR
 Use this parameter to define the IP block that is going to be used for this cloud network. This must be written in CIDR notation, for example, "172.16.0.0/24" with or without quotes.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file. 
 Please note that this switch is not supported for UK Cloud accounts

 .EXAMPLE
 PS C:\Users\Administrator> Add-CloudNetwork -CloudNetworkLabel DBServers -CloudNetworkCIDR 192.168.101.0/24 -Account prod
 This example shows how to spin up a new cloud network called DBServers, which will service IP block 192.168.101.0/24, in the account prod.

 .LINK
 http://docs.rackspace.com/networks/api/v2/cn-devguide/content/create_virtual_interface.html
#>
}

function Remove-CloudNetwork {

    Param(
        [Parameter(Position=0, Mandatory=$true)][string] $NetworkID = $(throw "Please provide netowrk ID with -CloudNetworkID parameter"),
        [Parameter(Position=1, Mandatory=$True)][string] $Account = $(throw "Please specify required Cloud Account with -account parameter"),
        [Parameter(Position=2, Mandatory=$False)][string]$RegionOverride
    )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

   try {
        # Retrieving authentication token
        Get-AuthToken($Account)
    
        # Setting variables needed to execute this function
        $NetURI = (Get-CloudURI("servers")) + "/os-networksv2/$NetworkID.xml"
    
        $DelCloudNet = Invoke-RestMethod -Uri $NetURI -Headers $HeaderDictionary -Method DELETE -ErrorAction Stop
    
        # Display remaining cloud networks as confirmation
        Get-CloudNetworks($Account)
    }
    catch {
        Invoke-Exception($error)
    }

 <#
 .SYNOPSIS
 The Remove-CloudNetwork cmdlet will delete Rackspace cloud network in the region specified in the PoshNova configuration file.

 .DESCRIPTION
 See synopsis.

 .PARAMETER NetworkID
 Use this parameter to define the network ID of the cloud network you are about to delete.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file. 
 Please note that this switch is not supported for UK Cloud accounts

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudNetwork -CloudNetworkID 88e316b1-8e69-4591-ba92-bea8bb1837f5 -Account prod
 This example shows how to delete a cloud network with an ID of 88e316b1-8e69-4591-ba92-bea8bb1837f5 from the account prod.

 .LINK
 http://docs.rackspace.com/servers/api/v2/cn-devguide/content/delete_network.html
#>
}

function Connect-VirtualInterface {

    Param(
        [Parameter(Position=0, Mandatory=$true)][string] $NetworkID = $(throw "Please provide network ID with -NetworkID parameter"),
        [Parameter(Position=1, Mandatory=$true)][string] $ServerID = $(throw "Please provide server ID with -ServerID parameter"),
        [Parameter(Position=2, Mandatory=$True)][string] $Account = $(throw "Please specify required Cloud Account with -account parameter"),
        [Parameter(Position=3, Mandatory=$False)][string]$RegionOverride
    )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

   try {
        # Retrieving authentication token
        Get-AuthToken($Account)
    
        # Setting variables needed to execute this function
        $URI = (Get-CloudURI("servers")) + "/servers/$ServerID/os-virtual-interfacesv2.xml"
        
        [xml]$XMLBody = '<?xml version="1.0" encoding="UTF-8"?>
            <virtual_interface
                network_id="'+$NetworkID+'"
            />'
        
        $VirtualNet = Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $XMLBody -ContentType application/xml -Method Post -ErrorAction Stop

        # Return the results
        $summary = (Get-VirtualInterfaces $ServerID $Account)
        return $summary;
    }
    catch {
        Invoke-Exception($error)
    }

 <#
 .SYNOPSIS
 The Connect-VirtualInterface cmdlet will create a new virtual network interface for a cloud server and attach it to an existing cloud network.

 .DESCRIPTION
 See synopsis.

 .PARAMETER NetworkID
 Use this parameter to define the network ID of the cloud network to which you wish to connect the new virtual interface.

 .PARAMETER ServerID
 Use this parameter to define the server ID of the cloud server for which you wish to query current virtual interfaces.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file. 
 Please note that this switch is not supported for UK Cloud accounts

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudNetwork -CloudNetworkID 88e316b1-8e69-4591-ba92-bea8bb1837f5 -Account prod
 This example shows how to delete a cloud network with an ID of 88e316b1-8e69-4591-ba92-bea8bb1837f5 from the account prod.

 .LINK
 http://docs.rackspace.com/servers/api/v2/cn-devguide/content/delete_network.html
#>
}

function Get-VirtualInterfaces {

    Param(
        [Parameter(Position=0, Mandatory=$True)] $ServerID = $(throw "Please provide server ID with -ServerID parameter"),
        [Parameter(Position=1, Mandatory=$True)][string] $Account = $(throw "Please specify required Cloud Account with -account parameter"),
        [Parameter(Position=2, Mandatory=$False)][string]$RegionOverride
    )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

   try {
        # Retrieving authentication token
        Get-AuthToken($Account)
    
        # Setting variables needed to execute this function
        $URI = (Get-CloudURI("servers")) + "/servers/$ServerID/os-virtual-interfacesv2.xml"
        
        $VirtualNet = (Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -ErrorAction Stop)

        # Display remaining cloud networks
        $VirtualNet.virtual_interfaces.virtual_interface | select id,mac_address,@{n="ip_address";e={($_.ip_address | select -expand address) -join ',' }}
    }
    catch {
        Invoke-Exception($error)
    }

 <#
 .SYNOPSIS
 The Get-VirtualInterface cmdlet will get a list of virtual network interfaces on a server and provide additional relevant cloud network details for the server in question.

 .DESCRIPTION
 See synopsis.

 .PARAMETER ServerID
 Use this parameter to define the server ID of the cloud server for which you wish to query current virtual interfaces.

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
 http://docs.rackspace.com/networks/api/v2/cn-devguide/content/list_virt_interfaces.html
#>
}

function Disconnect-VirtualInterface {

    Param(
        [Parameter(Position=0, Mandatory=$true)][string] $InterfaceID = $(throw "Please provide interface ID with -InterfaceID parameter"),
        [Parameter(Position=1, Mandatory=$true)][string] $ServerID = $(throw "Please provide network ID with -ServerID parameter"),
        [Parameter(Position=2, Mandatory=$True)][string] $Account = $(throw "Please specify required Cloud Account with -account parameter"),
        [Parameter(Position=3, Mandatory=$False)][string]$RegionOverride
    )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

   try {
        # Retrieving authentication token
        Get-AuthToken($Account)
    
        # Setting variables needed to execute this function
        $URI = (Get-CloudURI("servers")) + "/servers/$ServerID/os-virtual-interfacesv2/$InterfaceID"
        
        <#
        [xml]$XMLBody = '<?xml version="1.0" encoding="UTF-8"?>
            <virtual_interface
                network_id="'+$NetworkID+'"
            />'
        #>
        
        Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Method DELETE -ErrorAction Stop

        Write-Host "`n  Virtual interface ($InterfaceID) removal action initiated. `n  Please allow a few seconds for this change to be applied..."
    }
    catch {
        Invoke-Exception($error)
    }

 <#
 .SYNOPSIS
 The Disconnect-VirtualInterface cmdlet will delete a virtual network interface for the specified cloud server.

 .DESCRIPTION
 See synopsis.

 .PARAMETER InterfaceID
 Use this parameter to define the network ID of the cloud network you are about to delete.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file. 
 Please note that this switch is not supported for UK Cloud accounts

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudNetwork -NetworkID 88e316b1-8e69-4591-ba92-bea8bb1837f5 -Account prod
 This example shows how to delete a cloud network with an ID of 88e316b1-8e69-4591-ba92-bea8bb1837f5 from the account prod.

 .LINK
 http://docs.rackspace.com/networks/api/v2/cn-devguide/content/delete_virt_interface_api.html
 #>
}
