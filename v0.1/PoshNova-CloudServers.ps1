<############################################################################################
                           ___          _         __                
                          / _ \___  ___| |__   /\ \ \_____   ____ _ 
                         / /_)/ _ \/ __| '_ \ /  \/ / _ \ \ / / _` |
                        / ___/ (_) \__ \ | | / /\  / (_) \ V / (_| |
                        \/    \___/|___/_| |_\_\ \/ \___/ \_/ \__,_|
                                                    NextGen Servers

Authors
-----------
    Nielsen Pierce (nielsen.pierce@rackspace.co.uk)
    Alexei Andreyev (alexei.andreyev@rackspace.co.uk)
    Don Schenck (don.schenck@rackspace.com)
    
Description
-----------
PowerShell v3 module for interaction with NextGen Rackspace Cloud API (PoshNova) 

NextGen Servers v2.0 API reference
----------------------------------
http://docs.rackspace.com/servers/api/v2/cs-devguide/content/ch_preface.html

############################################################################################>

function Get-CloudLimits {

    Param(
        [Parameter (Position=0, Mandatory=$True)][string] $Account = $(throw "-Account required"),
        [Parameter (Position=1, Mandatory=$True)][string][ValidateSet("Absolute", "Rate")] $LimitType = $(throw "-LimitType required"),
        [Parameter (Position=2, Mandatory=$False)][string]$RegionOverride
    )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

    try {
        Get-AuthToken($account)
        $URI = (Get-CloudURI("servers")) + "/limits"

        switch ($LimitType){
            "Absolute"{
                $Limits = (Invoke-RestMethod -Uri $URI  -Headers $HeaderDictionary).limits.absolute
                break;
            }
            "Rate"{
                $Limits = ((Invoke-RestMethod -Uri $URI  -Headers $HeaderDictionary).limits.rate) | select uri -ExpandProperty limit | ft -AutoSize
                break;
            }
            default{
                throw "-LimitType can be either `'Absolute`' or `'Rate`'"
                break;
            }
        }
        return $Limits
    }
    catch {
        Invoke-Exception($_.Exception)
    }
<#
 .SYNOPSIS
 Retrieve current rate and absolute API limits for a cloud account account.

 .DESCRIPTION
 The Get-CloudLimits cmdlet will retrieve current absolute and API rate limits that apply for a given Cloud account.

 .PARAMETER LimitType
 This parameter switches output between Absolute and Rate limits that are in force on a given Cloud account.
 This parameter will accept either 'Absolute' or 'Rate' as possible inputs.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will override the default region set in PoshNova configuration file. 

 .EXAMPLE
 PS C:\> Get-CloudLimits -account prod -LimitType Rate
 This example will retreive API rate limits for an account.

 .EXAMPLE
 PS C:\> Get-CloudLimits -account prod -LimitType Absolute
 This example will retreive absolute Cloud account limits.

 .LINK
 
#>
}

function Get-CloudServerImages {
    
    Param(
        [Parameter (Position=0, Mandatory=$True)][string] $Account = $(throw "Please specify required Cloud Account with -account parameter"),
        [Parameter (Position=1, Mandatory=$False)][string]$RegionOverride
    )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

    try {
        
        # Retrieving authentication token
        Get-AuthToken($account)

        # Setting variables needed to execute this function
        $URI = (Get-CloudURI("servers")) + "/images/detail.xml"
        
	    # Making the call to the API for a list of available server images and storing data into a variable
	    [xml]$ServerImageList = (Invoke-RestMethod -Uri $URI  -Headers $HeaderDictionary).innerxml

	    # Since the response body is XML, we can use dot notation to show the information needed without further parsing.
	    return $ServerImageList.Images.Image;
    }
    catch {
        Invoke-Exception($_.Exception)
    }
<#
 .SYNOPSIS
 List available Cloud Server base OS and user images.

 .DESCRIPTION
 The Get-CloudServerImages cmdlet will retreive a list of all Rackspace Cloud Server image snapshots for a given account, including Rackspace's base OS images.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file. 

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudServerImages -Account prod
 This example shows how to get a list of all available images in the account prod

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudServerImages cloudus -RegionOverride DFW
 This example shows how to get a list of all available images for cloudus account in DFW region

 .LINK
 http://docs.rackspace.com/servers/api/v2/cs-devguide/content/Images-d1e4427.html
#>
}

function Get-CloudServers{
    Param(
        [Parameter (Position=0, Mandatory=$True)][string] $Account = $(throw "Please specify required Cloud Account with -account parameter"),
        [Parameter (Position=1, Mandatory=$False)][string]$RegionOverride
    )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

    try {
        
        # Retrieving authentication token
        Get-AuthToken($Account)

        # Setting variables needed to execute this function
        $URI = (Get-CloudURI("servers")) + "/servers/detail.xml"

        # Making the call to the API for a list of available servers and storing data into a variable
        [xml]$ServerList = (Invoke-RestMethod -Uri $URI  -Headers $HeaderDictionary).innerxml 
    
        # Handling empty response bodies indicating that no servers exist in the queried data center
        if ($ServerList.Servers.Server -eq $null) {
            Write-Verbose "You do not currently have any Cloud Servers provisioned in this region."
        }
        elseif($ServerList.Servers.Server -ne $null){
    		return $ServerList.Servers.Server;
        }
    }
    catch {
        Invoke-Exception($_.Exception)
    }
       
<#
 .SYNOPSIS
 Retrieve all clouod server instances.

 .DESCRIPTION
 The Get-CloudServers cmdlet will display a list of all cloud server instances on a given account in a given cloud region.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file. 

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudServers -account cloud
 This example shows how to get a list of all servers currently deployed in specified account.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudServers cloudus -RegionOverride ORD
 This example shows how to get a list of all servers currently deployed in specified account in ORD region.

 .LINK
 http://docs.rackspace.com/servers/api/v2/cs-devguide/content/List_Servers-d1e2078.html
#>
}

function Get-CloudServerDetails {

    Param(
        #[Parameter(Position=0,Mandatory=$false)][switch]$Bandwidth,
        [Parameter(Position=1,Mandatory=$true)][string]$ServerID = $(throw "Please specify required server ID with -ServerID parameter"),
        [Parameter(Position=2,Mandatory=$true)][string]$Account = $(throw "Please specify required Cloud Account with -Account parameter"),
        [Parameter (Position=3, Mandatory=$False)][string]$RegionOverride
    )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

    # Retrieving authentication token
    Get-AuthToken($Account)
    
    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("servers")) + "/servers/$ServerID"
    
    return (Invoke-RestMethod -Uri $URI  -Headers $HeaderDictionary -Method Get).server

<#
 .SYNOPSIS
 The Get-CloudServerDetails cmdlet will pull down a list of detailed information for a specific Rackspace Cloud Server.

 .DESCRIPTION
 This command is executed against one given cloud server ID, which in turn will return explicit details about that server without any other server data.

 .PARAMETER Bandwidth
 NOT IMPLEMENTED YET - Use this parameter to indicate that you'd like to see bandwidth statistics of the server ID passed to powershell.

 .PARAMETER CloudServerID
 Use this parameter to specify Cloud Server UUID, details of which you want query. Run the "Get-CloudServers" cmdlet for a complete listing of servers.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file. 

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudServerDetails -CloudServerID abc123ef-9876-abcd-1234-123456abcdef -Account prod
 This example shows how to get explicit data about one cloud server from the account Prod

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudServerDetails -CloudServerID abc123ef-9876-abcd-1234-123456abcdef -Account Dev -Bandwidth 
 NOT IMPLEMENTED YET - This example shows how to get explicit data about one cloud server from account Dev, including bandwidth statistics.

 PS C:\Users\mitch.robins> Get-CloudServerDetails -CloudServerID abc123ef-9876-abcd-1234-123456abcdef -Account Prod

    Server Status:  ACTIVE 
    Server Name:  AA-Mongo 
    Server ID:  abc123ef-9876-abcd-1234-123456abcdef
    Server Created:  2013-03-11T16:09:15Z 
    Server Last Updated:  2013-03-11T16:14:27Z 
    Server Image ID:  8a3a9f96-b997-46fd-b7a8-a9e740796ffd 
    Server Flavor ID:  4 
    Server IPv4:  100.100.100.100
    Server IPv6:  2001:::::::15d0 
    Server Build Progress:  100 

 .LINK
 http://docs.rackspace.com/servers/api/v2/cs-devguide/content/Get_Server_Details-d1e2623.html
#>
}

function Get-CloudServerFlavors {

    Param(
        [Parameter (Position=0, Mandatory=$True)][string] $Account = $(throw "Please specify required Cloud Account with -account parameter"),
        [Parameter (Position=1, Mandatory=$False)][string]$RegionOverride
    )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

    try {
        
        # Retrieving authentication token
        Get-AuthToken($Account)

        # Setting variables needed to execute this function
        $URI = (Get-CloudURI("servers")) + "/flavors/detail.xml"

        [xml]$ServerFlavorList = (Invoke-RestMethod -Uri $URI  -Headers $HeaderDictionary).innerxml
        
        return $ServerFlavorList.Flavors.Flavor;
        }
    catch {
        Invoke-Exception($_.Exception)
    }
<#
 .SYNOPSIS
 The Get-CloudServerFlavors cmdlet will pull down a list of cloud server flavors. Flavors are the predefined resource templates in Openstack.

 .DESCRIPTION
 See synopsis.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file. 
 Please note that this switch is not supported for UK Cloud accounts

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudServerFlavors -Account prod
 This example shows how to get flavor data for account Prod

  
 .LINK
 http://docs.rackspace.com/servers/api/v2/cs-devguide/content/Flavors-d1e4180.html

#>
}

function Get-CloudServerBlockVols {

    Param(
        [Parameter (Position=0, Mandatory=$True)][string] $ServerID = $(throw "Please specify required server ID with -ServerID parameter"),
        [Parameter (Position=1, Mandatory=$True)][string] $Account = $(throw "Please specify required Cloud Account with -Account parameter"),
        [Parameter (Position=2, Mandatory=$False)][string]$RegionOverride
    )

    #Show-UntestedWarning

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }


    Get-AuthToken($Account)

    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("servers")) + "/servers/$ServerID/os-volume_attachments.xml"
    #Set-Variable -Name AttServerURI -Value "https://$region.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$ServerID/os-volume_attachments.xml"
    
    [xml]$Attachments = (Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Method Get -ErrorAction Stop).InnerXml

    if (!$Attachments.volumeAttachments.volumeAttachment) {
        Write-Verbose "`nThis cloud server has no cloud block storage volumes attached.`n"
    }
    else {
        return ($Attachments.volumeAttachments.volumeAttachment | select serverid,device,volumeid);
    }
<#
 .SYNOPSIS
 Retreive all attached Cloud Block volumes on a server.

 .DESCRIPTION
 The Get-CloudServerBlockVols cmdlet will retrieve a list of all cloud block storage volume attachments to a cloud server.

 .PARAMETER ServerID
 Use this parameter to indicate the 32 character UUID of the cloud server which you wish to view storage attachments. If you need to find this information, you can run the "Get-CloudServers" cmdlet for a complete listing of servers.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file. 
 Please note that this switch is not supported for UK Cloud accounts

 .EXAMPLE
 PS C:\> Get-CloudServerBlockVols -ServerID e1dae019-c44b-4e3d-8418-e8b923a3dd8f -Account cloud
 This example shows how to retrieve a list of all attached cloud block storage volumes of the specified cloud server in the account prod.    

.LINK
http://docs.rackspace.com/servers/api/v2/cs-devguide/content/Volume_Attachment_Actions.html

#>
}

function Add-CloudServer {
    
    Param(
        [Parameter(Position=0,Mandatory=$true)][string]$ServerName = $(throw "Please specify server name with -ServerName parameter"),
        [Parameter(Position=1,Mandatory=$true)][string]$FlavorID = $(throw "Please specify server flavor with -FlavorID parameter"),
        [Parameter(Position=2,Mandatory=$true)][string]$ImageID = $(throw "Please specify the image ID with -ImageID parameter"),
        [Parameter(Position=3,Mandatory=$false)][array]$UserNetworks,
        [Parameter(Position=4,Mandatory=$true)][string]$Account = $(throw "Please specify required Cloud Account with -Account parameter"),
        [Parameter(Position=5,Mandatory=$false)][ValidateCount(0,5)][string[]]$File,
        [Parameter(Position=6,Mandatory=$false)][switch]$Isolated,
        [Parameter(Position=7,Mandatory=$false)][switch]$Deploy,
        [Parameter(Position=8,Mandatory=$false)][string]$RegionOverride
    )

    if($RegionOverride){
            $Global:RegionOverride = $RegionOverride
        }
    
    Get-AuthToken($Account)
    $URI = (Get-CloudURI("servers")) + "/servers"
    
    # Build our JSON object
    #
    $object = New-Object -TypeName PSCustomObject -Property @{
            "server"=New-Object -TypeName PSCustomObject -Property @{
                "name"=$ServerName;
                "imageRef"=$ImageID;
                "flavorRef"="$FlavorID";
                "personality"=@();
                "networks"=@()
            }
        }
    
    # Check if the default cloud networks should be added
    #
    if(!$Isolated){
            $UserNetworks += @("00000000-0000-0000-0000-000000000000","11111111-1111-1111-1111-111111111111")
        }
    
    # Add any user-specified networks to the JSON body
    #
    if($UserNetworks){
            foreach ($uuid in $UserNetworks){
                $object.server.networks += New-Object -TypeName PSCustomObject -Property @{"uuid"=$uuid}
            }
        }
    
    #Add injected file to request body if one is specified
    #
    if($File){
        foreach ($fileName in $File) {
            $content = Get-Content -Path $($fileName.Split("=")[1]) -Encoding Byte
            $content64 = [System.Convert]::ToBase64String($Content)
            $path = $fileName.Split("=")[0]
            $object.server.personality += New-Object -TypeName PSCustomObject -Property @{"path"=$path;"contents"=$content64}
        }
    }
		
    
    $JSONbody = $object | ConvertTo-Json -Depth 3
    
    $NewCloudServer = Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $JSONbody -ContentType application/json -Method Post -ErrorAction Stop
    
    $NewCloudServer.server | ft Id, adminPass
     
    if($Deploy){
            write-host " "
            if ((Test-Path -path "C:\opscode\chef\bin\knife") -ne $True) {
                write-host "Knife not installed, please install chef client http://www.opscode.com/chef/install.msi"
                break
            }
            
            write-host "Once Server built chef will be installed"

            $progress = Get-CloudServers -Account $account | where {$_.name -eq $CloudServerName} | select progress
            $status = Get-CloudServers -Account $account | where {$_.name -eq $CloudServerName} | select status

            while ($status -notlike "*Active*"){
                for ($i = 1; $i -le 5; $i++){
                    write-progress -id 1 -activity "Waiting for server build before bootstrapping...." -status "progress  $progress.progress" -percentComplete ($i*5); 
                    $progress = Get-CloudServers -Account $account | where {$_.name -eq $CloudServerName} | select progress
                    $status = Get-CloudServers -Account $account | where {$_.name -eq $CloudServerName} | select status
                    sleep 5
                }
            }
            $ID = Get-CloudServers -Account $account | where {$_.name -eq $CloudServerName} | select id
            $IP = Get-CloudServers -Account $account | where {$_.name -eq $CloudServerName} | select accessIPv4
            Write-host "Changing password....."

            $password = $NewCloudServer.server.adminPass
            $IP = $IP.accessIPv4
            $ID = $ID.id
            Update-CloudServer -account $account -CloudServerID $ID -UpdateAdminPassword $password
            sleep 10   
            write-host "knife bootstrap windows winrm $IP -x administrator -P $password"
            knife bootstrap windows winrm $IP -x administrator -P $password
            write-host ""
            write-host "Name: $CloudServerName"
            write-host "ID: "$ID
            write-host "Password: $password"
            write-host "IP: "$IP 
        }

 <#
 .SYNOPSIS
 The Add-CloudServer cmdlet will create a new Rackspace cloud server in the specified account.

 .DESCRIPTION
 See synopsis.

 .PARAMETER ServerName
 Use this parameter to define the name of the server you are about to create. Whatever you enter here will be exactly what is displayed as the server name in further API requests and/or the Rackspace Cloud Control Panel.

 .PARAMETER FlavorID
 Use this parameter to define the ID of the flavor that you would like applied to your new server.  If you are unsure of which flavor to use, run the "Get-CloudServerFlavors" command.

 .PARAMETER ImageID
 Use this parameter to define the ID of the image that you would like to build your new server from.  This can be a Rackspace provided base image, or an existing custom image snapshot that you've previously taken.  If you are unsure of which image to use, run the "Get-CloudServerImages" command.

 .PARAMETER UserNetworks
 Use this parameter to define the UUID of the first custom network you would like this server attached to.  If you do not later use the -Isolated switch, this server will be connected to this network and Rackspace default networks.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file. 
 Please note that this switch is not supported for UK Cloud accounts

 .PARAMETER Isolated
 Use this parameter to indiacte that you'd like this server to be in an isolated network.  Using this switch will render this server ONLY connected to the UUIDs of the custom networks you define.

 .PARAMETER File
 Use this parameter to inject a file into a new cloud server. The cmd will read in a file, convert to Base64 and inject onto server

 .EXAMPLE
 PS C:\Users\Administrator> Add-CloudServer -CloudServerName NewlyCreatedTestServer -CloudServerFlavorID 3 -CloudServerImageID 26fec9f2-2fb5-4e5e-a19f-0d12540ec639 -File "C:\\cloud-automation\\bootstrap.cmd=bootstrap.cmd" -Account prod
 This example shows how to spin up a new Windows Server 2012 cloud server called "NewlyCreatedTestServer" , with 1GB RAM, 1 vCPU, and 40GB of local storage, in the account prod

 .EXAMPLE
 PS C:\Users\Administrator> Add-CloudServer -CloudServerName NewlyCreatedTestServer -CloudServerFlavorID 3 -CloudServerImageID 26fec9f2-2fb5-4e5e-a19f-0d12540ec639 -Account prod
 This example shows how to spin up a new Windows Server 2012 cloud server called "NewlyCreatedTestServer" , with 1GB RAM, 1 vCPU, 40GB of local storage and inject source file bootstrap.cmd contents into c:\cloud-automation\bootstrap.cmd, in the account prod 
.LINK
http://docs.rackspace.com/servers/api/v2/cs-devguide/content/CreateServers.html

#>
}

function Add-CloudServerImage {

    Param(
        [Parameter(Position=0, Mandatory=$true)][string]$ServerID = $(throw "Please specify server ID with -CloudServerID parameter"),
        [Parameter(Position=1, Mandatory=$true)][string]$ImageName = $(throw "Please specify image name with -NewImageName parameter"),
        [Parameter(Position=2, Mandatory=$true)][string]$Account = $(throw "Please specify required Cloud Account with -Account parameter"),
        [Parameter(Position=3,Mandatory=$false)][string]$RegionOverride
    )
       
    if($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

    ## Setting variables needed to execute this function
    $XMLBody = '<?xml version="1.0" encoding="UTF-8"?>
        <createImage
            xmlns="http://docs.openstack.org/compute/api/v1.1"
            name="'+$NewImageName+'">
        </createImage>'

    try {
        
        # Retrieving authentication token
        Get-AuthToken($Account)

        $URI = (Get-CloudURI("servers")) + "/servers/$CloudServerID/action"

        Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $XMLBody -ContentType application/xml -Method Post -ErrorAction Stop
        Write-Host "Your new Rackspace Cloud Server image is being created."

	}
    catch {
        Invoke-Exception($_.Exception)
    }

<#
 .SYNOPSIS
 The Add-CloudServerImage cmdlet will create a new Rackspace cloud server image snapshot for the provided server id.

 .DESCRIPTION
 See synopsis.

 .PARAMETER ServerID
 Use this parameter to indicate the 32 character UUID of the cloud server of which you want explicit details. If you need to find this information, you can run the "Get-CloudServers" cmdlet for a complete listing of servers.

 .PARAMETER ImageName
 Use this parameter to define the name of the image snapshot that is about to be taken.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file. 
 Please note that this switch is not supported for UK Cloud accounts

 .EXAMPLE
 PS C:\Users\Administrator> Add-CloudServerImage  -CloudServerID abc123ef-9876-abcd-1234-123456abcdef -NewImageName SnapshotCopy1 -Region lon
 This example shows how to create a new server image snapshot of a serve, UUID of "abc123ef-9876-abcd-1234-123456abcdef", and the snapshot being titled "SnapshotCopy1" in the lon region.

 .LINK
 http://docs.rackspace.com/servers/api/v2/cs-devguide/content/Create_Image-d1e4655.html

#>
}

function Update-CloudServer {

    Param(
        [Parameter(Mandatory=$false)][string]$UpdateName,
        [Parameter(Mandatory=$false)][string]$UpdateIPv4Address, 
        [Parameter(Mandatory=$false)][string]$UpdateIPv6Address,
        [Parameter(Mandatory=$false)][string]$UpdateAdminPassword,
        [Parameter(Mandatory=$true)][string]$ServerID = $(throw "Please specify server ID with -CloudServerID parameter"),
        [Parameter(Mandatory=$true)][string]$Account = $(throw "Please specify required Cloud Account with -Account parameter")
    )

    # Show warning to identify untested cmdlet
    Show-UntestedWarning

    try {
        
        # Retrieving authentication token
        Get-AuthToken($Account)

        if ($UpdateName) {

            # Setting variables needed to execute this function
            [xml]$XMLBody = '<?xml version="1.0" encoding="UTF-8"?>
                <server
                    xmlns="http://docs.openstack.org/compute/api/v1.1"
                    name="'+$UpdateName+'"/>'

            $URI = (Get-CloudURI("servers")) + "/servers/$CloudServerID"

            Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $XMLBody -ContentType application/xml -Method Put -ErrorAction Stop | Out-Null
            Write-Host "Your Cloud Server has been updated. Please wait 10 seconds for a refreshed Cloud Server list."

            Sleep 10

            Get-CloudServers -Account $account
        }
        elseif ($UpdateIPv4Address) {
            [xml]$XMLBody = '<?xml version="1.0" encoding="UTF-8"?>
                <server
                    xmlns="http://docs.openstack.org/compute/api/v1.1"
                    accessIPv4="'+$UpdateIPv4Address+'"
                />'
            
            $URI = (Get-CloudURI("servers")) + "/servers/$CloudServerID"

            Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $XMLBody -ContentType application/xml -Method Post -ErrorAction Stop | Out-Null
            Write-Host "Your Cloud Server has been updated. Please wait 10 seconds for a refreshed Cloud Server list."
            Sleep 10
            Get-CloudServers -Account $account
        }
        elseif ($UpdateIPv6Address) {

            # Setting variables needed to execute this function
            [xml]$XMLBody = '<?xml version="1.0" encoding="UTF-8"?>
                <server
                    xmlns="http://docs.openstack.org/compute/api/v1.1"
                    accessIPv6="'+$UpdateIPv6Address+'"
                />'
    
            $URI = (Get-CloudURI("servers")) + "/servers/$CloudServerID"

            Invoke-RestMethod -Uri URI -Headers $HeaderDictionary -Body $XMLBody -ContentType application/xml -Method Post -ErrorAction Stop | Out-Null
            Write-Host "Your Cloud Server has been updated. Please wait 10 seconds for a refreshed Cloud Server list."
            Sleep 10
            Get-CloudServers -Account $account
        }
        elseif ($UpdateAdminPassword) {
    
            # Setting variables needed to execute this function
            [xml]$XMLBody = '<?xml version="1.0" encoding="UTF-8"?>
                <changePassword
                xmlns="http://docs.openstack.org/compute/api/v1.1"
                adminPass="'+$UpdateAdminPassword+'"/>'

            $URI = (Get-CloudURI("servers")) + "/servers/$CloudServerID/action"

            Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $XMLBody -ContentType application/xml -Method Post -ErrorAction Stop
            Write-Host "Your Cloud Server has been updated."
        }
    }
    catch {
        Invoke-Exception($_.Exception)
    }
 
<#
 .SYNOPSIS
 This command will update the name, IPv4/IPv6 address, and/or the administrative/root password of your Rackspace Cloud Server.

 .DESCRIPTION
 Using this command, you will be able to update: 
 
 1) The name of the Cloud Server
 2) The IPv4/IPv6 address
 3) The administrative/root password
 
 The usage of the command would look like this "Update-CloudServer -Switch NewValue".

 .PARAMETER UpdateName
 Using this switch would indicate that you would like to change the name of your Rackspace Cloud server.

 .PARAMETER UpdateIPv4Address
 Using this switch would indicate that you would like to change the IPv4 address of your Rackspace Cloud server.

 .PARAMETER UpdateIPv6Address
 Using this switch would indicate that you would like to change the IPv6 address of your Rackspace Cloud server.

 .PARAMETER UpdateAdminPassword
 Using this switch would indicate that you would like to change the adminitrative/root password within your Rackspace Cloud Server.

 .PARAMETER CloudServerID
 This field is meant to be the 32 character identifier of your Rackspace Cloud Server.  If you need to figure out the ID, run the "Get-CloudServers" command to retrieve a full list of servers and their IDs from your account.

 
 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against.  Valid choices are defined in Conf.xml

 .EXAMPLE
 PS C:\Users\Administrator> Update-CloudServer -Account prod -CloudServerID abc123ef-9876-abcd-1234-123456abcdef  -UpdateName  New-Windows-Web-Server
 This example shows the command to rename a Rackspace Cloud Server with an ID of "abc123ef-9876-abcd-1234-123456abcdef" to a new name of "New-Windows-Web-Server".

  .EXAMPLE
 PS C:\Users\Administrator> Update-CloudServer -Account prod -CloudServerID abc123ef-9876-abcd-1234-123456abcdef  -UpdateAdminPassword NewC0mplexPassw0rd!
 This example shows the command to update the adminsitrative password of a Rackspace Cloud Server with an ID of "abc123ef-9876-abcd-1234-123456abcdef" to a new password of "NewC0mplexPassw0rd!".

 .LINK
 http://docs.rackspace.com/servers/api/v2/cs-devguide/content/ServerUpdate.html

#>
}

function Restart-CloudServer {

    Param(
        [Parameter(Position=0,Mandatory=$true)][string]$ServerID = $(throw "Please specify server ID with -ServerID parameter"),
        [Parameter(Position=2, Mandatory=$true)][string]$Account = $(throw "Please specify required Cloud Account with -Account parameter"),
        [Parameter(Position=3,Mandatory=$false)][string]$RegionOverride,
        [Parameter(Position=2,Mandatory=$False)][switch]$Hard
    )

    # Retrieving authentication token
    Get-AuthToken($Account)
    
    $URI = (Get-CloudURI("servers")) + "/servers/$ServerID/action"
    
    if($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

    if($Hard){
        $RebootType = "HARD"
    }
    else {
        $RebootType = "SOFT"
    }

    # Build our JSON object
    #
    $object = New-Object -TypeName PSCustomObject -Property @{
        "reboot"=New-Object -TypeName PSCustomObject -Property @{
            "type" = "$RebootType"
        }
    }

    $JSONbody = $object | ConvertTo-Json -Depth 2
    
    Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $JSONbody -ContentType application/json -Method Post -ErrorAction Stop
    
<#
 .SYNOPSIS
 The Restart-CloudServer cmdlet will carry out a soft reboot of the specified cloud server.

 .DESCRIPTION
 See synopsis.

 .PARAMETER ServerID
 Use this parameter to indicate the 32 character UUID of the cloud server of which you want to reboot. If you need to find this information, you can run the "Get-CloudServers" cmdlet for a complete listing of servers.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file. 
 Please note that this switch is not supported for UK Cloud accounts

 .PARAMETER Hard
 Use this switch to indicate that you would like the server be hard rebooted, as opposed to the default of a soft reboot.

 .EXAMPLE
 PS C:\Users\Administrator> Restart-CloudServer  -ServerID abc123ef-9876-abcd-1234-123456abcdef -account prod
 This example shows how to request a soft reboot of cloud server, UUID of abc123ef-9876-abcd-1234-123456abcdef, in the lon region.

 .EXAMPLE
 PS C:\Users\Administrator> Restart-CloudServer  -ServerID abc123ef-9876-abcd-1234-123456abcdef -account prod -Hard
 This example shows how to request a hard reboot of cloud server, UUID of abc123ef-9876-abcd-1234-123456abcdef, in the lon region.

 .LINK
 http://docs.rackspace.com/servers/api/v2/cs-devguide/content/Reboot_Server-d1e3371.html

#>    
 }

<#
function Resize-CloudServer {

    Param(
        [Parameter(Mandatory=$False)][switch]$Confirm,
        [Parameter(Mandatory=$False)][switch]$Revert,
        [Parameter(Mandatory=$true)][string]$CloudServerID = $(throw "Please specify server ID with -CloudServerID parameter"),
        [Parameter(Mandatory=$true)][string]$Account = $(throw "Please specify required Cloud Account with -Account parameter"),
        [Parameter(Mandatory=$False)][int]$CloudServerFlavorID
    )

    #
    #
    #
    # Missing logic - cmdlet incomplete!
    #
    # Show warning to identify untested cmdlet
    Show-UntestedWarning


    try {
        
        Write-Host "`nWarnming: This cmdlet and corresponding API call are deprecated.`n" -ForegroundColor Yellow

        throw "This function is not implemented yet!" 

        # Retrieving authentication token
        Get-AuthToken($Account)

        $URI = (Get-CloudURI("servers")) + "/servers/$CloudServerID/action"


        if ($Confirm) {
            $XMLBody = '<?xml version="1.0" encoding="UTF-8"?>
                <confirmResize
                xmlns="http://docs.openstack.org/compute/api/v1.1"/>'

            Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $XMLBody -ContentType application/xml -Method Post -ErrorAction Stop
            Write-Host "The resize action of your server has been confirmed."
        }
        elseif ($Revert) {
            $XMLBody = '<?xml version="1.0" encoding="UTF-8"?>
                <revertResize
                xmlns="http://docs.openstack.org/compute/api/v1.1"/>'

            Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $XMLBody -ContentType application/xml -Method Post -ErrorAction Stop
            Write-Host "Revert to previous size/ste has been initiated."
        }
        else {
            $XMLBody = '<?xml version="1.0" encoding="UTF-8"?>
                <resize
                xmlns="http://docs.openstack.org/compute/api/v1.1"/>'
            


            Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $XMLBody -ContentType application/xml -Method Post -ErrorAction Stop
            Write-Host "Resize process has been initiated."

        }
	}
    catch {
        Invoke-Exception($_.Exception)
    }

<#
 .SYNOPSIS
 The Resize-CloudServer cmdlet will resize the specified cloud server to a new flavor.  After the original request, you can also use this command to either REVERT your changes, or CONFIRM them.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudServerID
 Use this parameter to indicate the 32 character UUID of the cloud server which you want to resize. If you need to find this information, you can run the "Get-CloudServers" cmdlet for a complete listing of servers.

 .PARAMETER Account
 Use this parameter to indicate the account number for which you would like to execute this request.

 .PARAMETER CloudServerFlavorID
 Use this parameter to define the ID of the flavor that you would like to resize to for the server specified.  If you are unsure of which flavor to use, run the "Get-CloudServerFlavors" command.

 .PARAMETER Confirm
 Use this switch to indicate that you would like to confirm the requested resize be fully applied after testing your cloud server.  You should only use the confirm switch after the original request to resize the server and have verified everything is working as expected.

 .PARAMETER Revert
 Use this switch to indicate that you would like to revert the newly resized server to its previous state.  This will permanently undo the original resize operation.

 .EXAMPLE
 PS C:\Users\Administrator> Resize-CloudServer  -CloudServerID abc123ef-9876-abcd-1234-123456abcdef -Region lon -CloudServerFlavorID 3
 This example shows how to resize a server, UUID of abc123ef-9876-abcd-1234-123456abcdef, in the lon region, to a new size of 1GB RAM, 1 vCPU, 40GB storage.

 .EXAMPLE
 PS C:\Users\Administrator> Resize-CloudServer  -CloudServerID abc123ef-9876-abcd-1234-123456abcdef -Region ORD -Confirm
 This example shows how to confirm the resizing of a server, UUID of abc123ef-9876-abcd-1234-123456abcdef, in the ORD region.

 .EXAMPLE
 PS C:\Users\Administrator> Resize-CloudServer  -CloudServerID abc123ef-9876-abcd-1234-123456abcdef -Region ORD -Revert
 This example shows how to revert the resizing of a server, UUID of abc123ef-9876-abcd-1234-123456abcdef, in the ORD region, back to its previous size.

 .LINK
 http://docs.rackspace.com/servers/api/v2/cs-devguide/content/Resize_Server-d1e3707.html

#>
#}
#>

function Remove-CloudServer { 

    Param(
        [Parameter(Position=0,Mandatory=$true)][string]$ServerID = $(throw "Please specify server ID with -ServerID parameter"),
        [Parameter(Position=1, Mandatory=$true)][string]$Account = $(throw "Please specify required Cloud Account with -Account parameter"),
        [Parameter(Position=2,Mandatory=$false)][string]$RegionOverride
        )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

    Get-AuthToken($Account)
    $URI = (Get-CloudURI("servers")) + "/servers/$ServerID"

    Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Method Delete -ErrorAction Stop

    if (!$?) {
        break;
    }
    else {
        Write-Verbose "Your server has been scheduled for deletion. This action will take up to a minute to complete."
    }

<#
 .SYNOPSIS
 The Remove-CloudServer cmdlet will permanently delete a cloud server from your account.

 .DESCRIPTION
 See synopsis.

 .PARAMETER ServerID
 Use this parameter to indicate the 32 character UUID of the cloud server that you would like to delete. If you need to find this information, you can run the "Get-CloudServers" cmdlet for a complete listing of servers.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file. 
 Please note that this switch is not supported for UK Cloud accounts

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudServer  -CloudServerID abc123ef-9876-abcd-1234-123456abcdef -Account prod
 This example shows how to delete a server, UUID of abc123ef-9876-abcd-1234-123456abcdef, from the account prod

 
 .LINK
 http://docs.rackspace.com/servers/api/v2/cs-devguide/content/Delete_Server-d1e2883.html

#>
}

function Remove-CloudServerImage {

    Param(
        [Parameter(Position=0,Mandatory=$true)][string]$ServerImageID = $(throw "Please specify image ID with -ServerImageID parameter"),
        [Parameter(Position=1, Mandatory=$true)][string]$Account = $(throw "Please specify required Cloud Account with -Account parameter"),
        [Parameter(Position=2,Mandatory=$false)][string]$RegionOverride
        )

    # Retrieving authentication token
    Get-AuthToken($Account)

    $URI = (Get-CloudURI("servers")) + "/images/$ServerImageID"

    Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Method Delete -ErrorAction Stop
    Write-Host "Your Rackspace Cloud Server Image has been deleted."

<#
 .SYNOPSIS
 The Remove-CloudServerImage cmdlet will permanently delete a cloud server image snapshot from your account.

 .DESCRIPTION
 See synopsis.

 .PARAMETER ServerImageID
 Use this parameter to define the ID of the image that you would like to delete. If you are unsure of the image ID, run the "Get-CloudServerImages" command.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file. 
 Please note that this switch is not supported for UK Cloud accounts

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudServerImage  -CloudServerImageID abc123ef-9876-abcd-1234-123456abcdef -Region lon 
 This example shows how to delete a server image snapshot, UUID of abc123ef-9876-abcd-1234-123456abcdef, from the lon region.

 .EXAMPLE
 PS C:\Users\Administrator> Restart-CloudServerImage  abc123ef-9876-abcd-1234-123456abcdef ORD
 This example shows how to delete a server image snapshot, UUID of abc123ef-9876-abcd-1234-123456abcdef, from the ORD region, without using the parameter names.

 .LINK
 http://docs.rackspace.com/servers/api/v2/cs-devguide/content/Delete_Image-d1e4957.html

#>
}

function Set-CloudServerRescueMode {
    
    Param(
        [Parameter(Position=0,Mandatory=$true)][string]$CloudServerID = $(throw "Please specify server ID with -CloudServerID parameter"),
        [Parameter(Position=1, Mandatory=$true)][string]$Account = $(throw "Please specify required Cloud Account with -Account parameter"),
        [Parameter(Position=2,Mandatory=$false)][string]$RegionOverride,
        [Parameter(Position=2,Mandatory=$false)][switch]$Unrescue
    )

    # Show warning to identify untested cmdlet
    Show-UntestedWarning

    # Retrieving authentication token
    Get-AuthToken($Account)

    $URI = (Get-CloudURI("servers")) + "/servers/$CloudServerID/action"

    if ($Unrescue) {
        [xml]$XMLBody = '<?xml version="1.0" encoding="UTF-8"?>
        <unrescue xmlns="http://docs.rackspacecloud.com/servers/api/v1.1" />'
    
        $RescueMode = Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $XMLBody -ContentType application/xml -Method Post -ErrorAction Stop
        Write-Host "Your server is being restored to normal service. `nPlease wait for the status of the server to show ACTIVE before carrying out any further commands against it."
    }
    else {
        [xml]$XMLBody = '<?xml version="1.0" encoding="UTF-8"?>
        <rescue xmlns="http://docs.openstack.org/compute/ext/rescue/api/v1.1" />'
        
        $RescueModePass = (Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $XMLBody -ContentType application/xml -Method Post -ErrorAction Stop).adminPass
    
        Write-Host "Rescue Mode takes 5 - 10 minutes to enable. 
                    `nPlease do not interact with this server again until it's status is RESCUE.
                    `nYour temporary password in rescue mode is: $RescueModePass"
    }
}#########>

function Get-CloudLimits {

    Param(
        [Parameter (Position=0, Mandatory=$True)][string] $Account = $(throw "-Account required"),
        [Parameter (Position=1, Mandatory=$True)][string][ValidateSet("Absolute", "Rate")] $LimitType = $(throw "-LimitType required"),
        [Parameter (Position=2, Mandatory=$False)][string]$RegionOverride
    )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

    try {
        Get-AuthToken($account)
        $URI = (Get-CloudURI("servers")) + "/limits"

        switch ($LimitType){
            "Absolute"{
                $Limits = (Invoke-RestMethod -Uri $URI  -Headers $HeaderDictionary).limits.absolute
                break;
            }
            "Rate"{
                $Limits = ((Invoke-RestMethod -Uri $URI  -Headers $HeaderDictionary).limits.rate) | select uri -ExpandProperty limit | ft -AutoSize
                break;
            }
            default{
                throw "-LimitType can be either `'Absolute`' or `'Rate`'"
                break;
            }
        }
        return $Limits
    }
    catch {
        Invoke-Exception($_.Exception)
    }
<#
 .SYNOPSIS
 Retrieve current rate and absolute API limits for a cloud account account.

 .DESCRIPTION
 The Get-CloudLimits cmdlet will retrieve current absolute and API rate limits that apply for a given Cloud account.

 .PARAMETER LimitType
 This parameter switches output between Absolute and Rate limits that are in force on a given Cloud account.
 This parameter will accept either 'Absolute' or 'Rate' as possible inputs.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will override the default region set in PoshNova configuration file. 

 .EXAMPLE
 PS C:\> Get-CloudLimits -account prod -LimitType Rate
 This example will retreive API rate limits for an account.

 .EXAMPLE
 PS C:\> Get-CloudLimits -account prod -LimitType Absolute
 This example will retreive absolute Cloud account limits.

 .LINK
 
#>
}

function Get-CloudServerImages {
    
    Param(
        [Parameter (Position=0, Mandatory=$True)][string] $Account = $(throw "Please specify required Cloud Account with -account parameter"),
        [Parameter (Position=1, Mandatory=$False)][string]$RegionOverride
    )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

    try {
        
        # Retrieving authentication token
        Get-AuthToken($account)

        # Setting variables needed to execute this function
        $URI = (Get-CloudURI("servers")) + "/images/detail.xml"
        
	    # Making the call to the API for a list of available server images and storing data into a variable
	    [xml]$ServerImageList = (Invoke-RestMethod -Uri $URI  -Headers $HeaderDictionary).innerxml

	    # Since the response body is XML, we can use dot notation to show the information needed without further parsing.
	    return $ServerImageList.Images.Image;
    }
    catch {
        Invoke-Exception($_.Exception)
    }
<#
 .SYNOPSIS
 List available Cloud Server base OS and user images.

 .DESCRIPTION
 The Get-CloudServerImages cmdlet will retreive a list of all Rackspace Cloud Server image snapshots for a given account, including Rackspace's base OS images.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file. 

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudServerImages -Account prod
 This example shows how to get a list of all available images in the account prod

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudServerImages cloudus -RegionOverride DFW
 This example shows how to get a list of all available images for cloudus account in DFW region

 .LINK
 http://docs.rackspace.com/servers/api/v2/cs-devguide/content/Images-d1e4427.html
#>
}

function Get-CloudServers{
    Param(
        [Parameter (Position=0, Mandatory=$True)][string] $Account = $(throw "Please specify required Cloud Account with -account parameter"),
        [Parameter (Position=1, Mandatory=$False)][string]$RegionOverride
    )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

    try {
        
        # Retrieving authentication token
        Get-AuthToken($Account)

        # Setting variables needed to execute this function
        $URI = (Get-CloudURI("servers")) + "/servers/detail.xml"

        # Making the call to the API for a list of available servers and storing data into a variable
        [xml]$ServerList = (Invoke-RestMethod -Uri $URI  -Headers $HeaderDictionary).innerxml 
    
        # Handling empty response bodies indicating that no servers exist in the queried data center
        if ($ServerList.Servers.Server -eq $null) {
            Write-Verbose "You do not currently have any Cloud Servers provisioned in this region."
        }
        elseif($ServerList.Servers.Server -ne $null){
    		return $ServerList.Servers.Server;
        }
    }
    catch {
        Invoke-Exception($_.Exception)
    }
       
<#
 .SYNOPSIS
 Retrieve all clouod server instances.

 .DESCRIPTION
 The Get-CloudServers cmdlet will display a list of all cloud server instances on a given account in a given cloud region.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file. 

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudServers -account cloud
 This example shows how to get a list of all servers currently deployed in specified account.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudServers cloudus -RegionOverride ORD
 This example shows how to get a list of all servers currently deployed in specified account in ORD region.

 .LINK
 http://docs.rackspace.com/servers/api/v2/cs-devguide/content/List_Servers-d1e2078.html
#>
}

function Get-CloudServerDetails {

    Param(
        #[Parameter(Position=0,Mandatory=$false)][switch]$Bandwidth,
        [Parameter(Position=1,Mandatory=$true)][string]$ServerID = $(throw "Please specify required server ID with -ServerID parameter"),
        [Parameter(Position=2,Mandatory=$true)][string]$Account = $(throw "Please specify required Cloud Account with -Account parameter"),
        [Parameter (Position=3, Mandatory=$False)][string]$RegionOverride
    )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

    # Retrieving authentication token
    Get-AuthToken($Account)
    
    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("servers")) + "/servers/$ServerID"
    
    return (Invoke-RestMethod -Uri $URI  -Headers $HeaderDictionary -Method Get).server

<#
 .SYNOPSIS
 The Get-CloudServerDetails cmdlet will pull down a list of detailed information for a specific Rackspace Cloud Server.

 .DESCRIPTION
 This command is executed against one given cloud server ID, which in turn will return explicit details about that server without any other server data.

 .PARAMETER Bandwidth
 NOT IMPLEMENTED YET - Use this parameter to indicate that you'd like to see bandwidth statistics of the server ID passed to powershell.

 .PARAMETER CloudServerID
 Use this parameter to specify Cloud Server UUID, details of which you want query. Run the "Get-CloudServers" cmdlet for a complete listing of servers.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file. 

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudServerDetails -CloudServerID abc123ef-9876-abcd-1234-123456abcdef -Account prod
 This example shows how to get explicit data about one cloud server from the account Prod

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudServerDetails -CloudServerID abc123ef-9876-abcd-1234-123456abcdef -Account Dev -Bandwidth 
 NOT IMPLEMENTED YET - This example shows how to get explicit data about one cloud server from account Dev, including bandwidth statistics.

 PS C:\Users\mitch.robins> Get-CloudServerDetails -CloudServerID abc123ef-9876-abcd-1234-123456abcdef -Account Prod

    Server Status:  ACTIVE 
    Server Name:  AA-Mongo 
    Server ID:  abc123ef-9876-abcd-1234-123456abcdef
    Server Created:  2013-03-11T16:09:15Z 
    Server Last Updated:  2013-03-11T16:14:27Z 
    Server Image ID:  8a3a9f96-b997-46fd-b7a8-a9e740796ffd 
    Server Flavor ID:  4 
    Server IPv4:  100.100.100.100
    Server IPv6:  2001:::::::15d0 
    Server Build Progress:  100 

 .LINK
 http://docs.rackspace.com/servers/api/v2/cs-devguide/content/Get_Server_Details-d1e2623.html
#>
}

function Get-CloudServerFlavors {

    Param(
        [Parameter (Position=0, Mandatory=$True)][string] $Account = $(throw "Please specify required Cloud Account with -account parameter"),
        [Parameter (Position=1, Mandatory=$False)][string]$RegionOverride
    )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

    try {
        
        # Retrieving authentication token
        Get-AuthToken($Account)

        # Setting variables needed to execute this function
        $URI = (Get-CloudURI("servers")) + "/flavors/detail.xml"

        [xml]$ServerFlavorList = (Invoke-RestMethod -Uri $URI  -Headers $HeaderDictionary).innerxml
        
        return $ServerFlavorList.Flavors.Flavor;
        }
    catch {
        Invoke-Exception($_.Exception)
    }
<#
 .SYNOPSIS
 The Get-CloudServerFlavors cmdlet will pull down a list of cloud server flavors. Flavors are the predefined resource templates in Openstack.

 .DESCRIPTION
 See synopsis.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file. 
 Please note that this switch is not supported for UK Cloud accounts

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudServerFlavors -Account prod
 This example shows how to get flavor data for account Prod

  
 .LINK
 http://docs.rackspace.com/servers/api/v2/cs-devguide/content/Flavors-d1e4180.html

#>
}

function Get-CloudServerBlockVols {

    Param(
        [Parameter (Position=0, Mandatory=$True)][string] $ServerID = $(throw "Please specify required server ID with -ServerID parameter"),
        [Parameter (Position=1, Mandatory=$True)][string] $Account = $(throw "Please specify required Cloud Account with -Account parameter"),
        [Parameter (Position=2, Mandatory=$False)][string]$RegionOverride
    )

    #Show-UntestedWarning

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }


    Get-AuthToken($Account)

    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("servers")) + "/servers/$ServerID/os-volume_attachments.xml"
    #Set-Variable -Name AttServerURI -Value "https://$region.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$ServerID/os-volume_attachments.xml"
    
    [xml]$Attachments = (Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Method Get -ErrorAction Stop).InnerXml

    if (!$Attachments.volumeAttachments.volumeAttachment) {
        Write-Verbose "`nThis cloud server has no cloud block storage volumes attached.`n"
    }
    else {
        return ($Attachments.volumeAttachments.volumeAttachment | select serverid,device,volumeid);
    }
<#
 .SYNOPSIS
 Retreive all attached Cloud Block volumes on a server.

 .DESCRIPTION
 The Get-CloudServerBlockVols cmdlet will retrieve a list of all cloud block storage volume attachments to a cloud server.

 .PARAMETER ServerID
 Use this parameter to indicate the 32 character UUID of the cloud server which you wish to view storage attachments. If you need to find this information, you can run the "Get-CloudServers" cmdlet for a complete listing of servers.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file. 
 Please note that this switch is not supported for UK Cloud accounts

 .EXAMPLE
 PS C:\> Get-CloudServerBlockVols -ServerID e1dae019-c44b-4e3d-8418-e8b923a3dd8f -Account cloud
 This example shows how to retrieve a list of all attached cloud block storage volumes of the specified cloud server in the account prod.    

.LINK
http://docs.rackspace.com/servers/api/v2/cs-devguide/content/Volume_Attachment_Actions.html

#>
}

function Add-CloudServer {
    
    Param(
        [Parameter(Position=0,Mandatory=$true)][string]$ServerName = $(throw "Please specify server name with -ServerName parameter"),
        [Parameter(Position=1,Mandatory=$true)][string]$FlavorID = $(throw "Please specify server flavor with -FlavorID parameter"),
        [Parameter(Position=2,Mandatory=$true)][string]$ImageID = $(throw "Please specify the image ID with -ImageID parameter"),
        [Parameter(Position=3,Mandatory=$false)][array]$UserNetworks,
        [Parameter(Position=4,Mandatory=$true)][string]$Account = $(throw "Please specify required Cloud Account with -Account parameter"),
        [Parameter(Position=5,Mandatory=$false)][array]$File,
        [Parameter(Position=6,Mandatory=$false)][switch]$Isolated,
        [Parameter(Position=7,Mandatory=$false)][switch]$Deploy,
        [Parameter(Position=8,Mandatory=$false)][string]$RegionOverride
    )

    if($RegionOverride){
            $Global:RegionOverride = $RegionOverride
        }
    
    Get-AuthToken($Account)
    $URI = (Get-CloudURI("servers")) + "/servers"
    
    # Build our JSON object
    #
    $object = New-Object -TypeName PSCustomObject -Property @{
            "server"=New-Object -TypeName PSCustomObject -Property @{
                "name"=$ServerName;
                "imageRef"=$ImageID;
                "flavorRef"="$FlavorID";
                "personality"=@();
                "networks"=@()
            }
        }
    
    # Check if the default cloud networks should be added
    #
    if(!$Isolated){
            $UserNetworks += @("00000000-0000-0000-0000-000000000000","11111111-1111-1111-1111-111111111111")
        }
    
    # Add any user-specified networks to the JSON body
    #
    if($UserNetworks){
            foreach ($uuid in $UserNetworks){
              $object.server.networks += New-Object -TypeName PSCustomObject -Property @{"uuid"=$uuid}
            }
        }
    
    #Add injected file to request body if one is specified
    #
    if($File){
		foreach ($fileName in $File) {
            $content = Get-Content -Path $($fileName.Split("=")[1]) -Encoding Byte
            $content64 = [System.Convert]::ToBase64String($Content)
            $path = $fileName.Split("=")[0]
            $object.server.personality += New-Object -TypeName PSCustomObject -Property @{"path"=$path;"contents"=$content64}
			}
		}
		
    
    $JSONbody = $object | ConvertTo-Json -Depth 3
    
    $NewCloudServer = Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $JSONbody -ContentType application/json -Method Post -ErrorAction Stop
    
    $NewCloudServer.server | ft Id, adminPass
     
    if($Deploy){
            write-host " "
            if ((Test-Path -path "C:\opscode\chef\bin\knife") -ne $True) {
                write-host "Knife not installed, please install chef client http://www.opscode.com/chef/install.msi"
                break
            }
            
            write-host "Once Server built chef will be installed"

            $progress = Get-CloudServers -Account $account | where {$_.name -eq $CloudServerName} | select progress
            $status = Get-CloudServers -Account $account | where {$_.name -eq $CloudServerName} | select status

            while ($status -notlike "*Active*"){
                for ($i = 1; $i -le 5; $i++){
                    write-progress -id 1 -activity "Waiting for server build before bootstrapping...." -status "progress  $progress.progress" -percentComplete ($i*5); 
                    $progress = Get-CloudServers -Account $account | where {$_.name -eq $CloudServerName} | select progress
                    $status = Get-CloudServers -Account $account | where {$_.name -eq $CloudServerName} | select status
                    sleep 5
                }
            }
            $ID = Get-CloudServers -Account $account | where {$_.name -eq $CloudServerName} | select id
            $IP = Get-CloudServers -Account $account | where {$_.name -eq $CloudServerName} | select accessIPv4
            Write-host "Changing password....."

            $password = $NewCloudServer.server.adminPass
            $IP = $IP.accessIPv4
            $ID = $ID.id
            Update-CloudServer -account $account -CloudServerID $ID -UpdateAdminPassword $password
            sleep 10   
            write-host "knife bootstrap windows winrm $IP -x administrator -P $password"
            knife bootstrap windows winrm $IP -x administrator -P $password
            write-host ""
            write-host "Name: $CloudServerName"
            write-host "ID: "$ID
            write-host "Password: $password"
            write-host "IP: "$IP 
        }

 <#
 .SYNOPSIS
 The Add-CloudServer cmdlet will create a new Rackspace cloud server in the specified account.

 .DESCRIPTION
 See synopsis.

 .PARAMETER ServerName
 Use this parameter to define the name of the server you are about to create. Whatever you enter here will be exactly what is displayed as the server name in further API requests and/or the Rackspace Cloud Control Panel.

 .PARAMETER FlavorID
 Use this parameter to define the ID of the flavor that you would like applied to your new server.  If you are unsure of which flavor to use, run the "Get-CloudServerFlavors" command.

 .PARAMETER ImageID
 Use this parameter to define the ID of the image that you would like to build your new server from.  This can be a Rackspace provided base image, or an existing custom image snapshot that you've previously taken.  If you are unsure of which image to use, run the "Get-CloudServerImages" command.

 .PARAMETER UserNetworks
 Use this parameter to define the UUID of the first custom network you would like this server attached to.  If you do not later use the -Isolated switch, this server will be connected to this network and Rackspace default networks.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file. 
 Please note that this switch is not supported for UK Cloud accounts

 .PARAMETER Isolated
 Use this parameter to indiacte that you'd like this server to be in an isolated network.  Using this switch will render this server ONLY connected to the UUIDs of the custom networks you define.

 .PARAMETER File
 Use this parameter to inject a file into a new cloud server. The cmd will read in a file, convert to Base64 and inject onto server

 .EXAMPLE
 PS C:\Users\Administrator> Add-CloudServer -CloudServerName NewlyCreatedTestServer -CloudServerFlavorID 3 -CloudServerImageID 26fec9f2-2fb5-4e5e-a19f-0d12540ec639 -File "C:\\cloud-automation\\bootstrap.cmd=bootstrap.cmd" -Account prod
 This example shows how to spin up a new Windows Server 2012 cloud server called "NewlyCreatedTestServer" , with 1GB RAM, 1 vCPU, and 40GB of local storage, in the account prod

 .EXAMPLE
 PS C:\Users\Administrator> Add-CloudServer -CloudServerName NewlyCreatedTestServer -CloudServerFlavorID 3 -CloudServerImageID 26fec9f2-2fb5-4e5e-a19f-0d12540ec639 -Account prod
 This example shows how to spin up a new Windows Server 2012 cloud server called "NewlyCreatedTestServer" , with 1GB RAM, 1 vCPU, 40GB of local storage and inject source file bootstrap.cmd contents into c:\cloud-automation\bootstrap.cmd, in the account prod 
.LINK
http://docs.rackspace.com/servers/api/v2/cs-devguide/content/CreateServers.html

#>
}

function Add-CloudServerImage {

    Param(
        [Parameter(Position=0, Mandatory=$true)][string]$ServerID = $(throw "Please specify server ID with -CloudServerID parameter"),
        [Parameter(Position=1, Mandatory=$true)][string]$ImageName = $(throw "Please specify image name with -NewImageName parameter"),
        [Parameter(Position=2, Mandatory=$true)][string]$Account = $(throw "Please specify required Cloud Account with -Account parameter"),
        [Parameter(Position=3,Mandatory=$false)][string]$RegionOverride
    )
       
    if($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

    ## Setting variables needed to execute this function
    $XMLBody = '<?xml version="1.0" encoding="UTF-8"?>
        <createImage
            xmlns="http://docs.openstack.org/compute/api/v1.1"
            name="'+$NewImageName+'">
        </createImage>'

    try {
        
        # Retrieving authentication token
        Get-AuthToken($Account)

        $URI = (Get-CloudURI("servers")) + "/servers/$CloudServerID/action"

        Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $XMLBody -ContentType application/xml -Method Post -ErrorAction Stop
        Write-Host "Your new Rackspace Cloud Server image is being created."

	}
    catch {
        Invoke-Exception($_.Exception)
    }

<#
 .SYNOPSIS
 The Add-CloudServerImage cmdlet will create a new Rackspace cloud server image snapshot for the provided server id.

 .DESCRIPTION
 See synopsis.

 .PARAMETER ServerID
 Use this parameter to indicate the 32 character UUID of the cloud server of which you want explicit details. If you need to find this information, you can run the "Get-CloudServers" cmdlet for a complete listing of servers.

 .PARAMETER ImageName
 Use this parameter to define the name of the image snapshot that is about to be taken.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file. 
 Please note that this switch is not supported for UK Cloud accounts

 .EXAMPLE
 PS C:\Users\Administrator> Add-CloudServerImage  -CloudServerID abc123ef-9876-abcd-1234-123456abcdef -NewImageName SnapshotCopy1 -Region lon
 This example shows how to create a new server image snapshot of a serve, UUID of "abc123ef-9876-abcd-1234-123456abcdef", and the snapshot being titled "SnapshotCopy1" in the lon region.

 .LINK
 http://docs.rackspace.com/servers/api/v2/cs-devguide/content/Create_Image-d1e4655.html

#>
}

function Update-CloudServer {

    Param(
        [Parameter(Mandatory=$false)][string]$UpdateName,
        [Parameter(Mandatory=$false)][string]$UpdateIPv4Address, 
        [Parameter(Mandatory=$false)][string]$UpdateIPv6Address,
        [Parameter(Mandatory=$false)][string]$UpdateAdminPassword,
        [Parameter(Mandatory=$true)][string]$ServerID = $(throw "Please specify server ID with -CloudServerID parameter"),
        [Parameter(Mandatory=$true)][string]$Account = $(throw "Please specify required Cloud Account with -Account parameter")
    )

    # Show warning to identify untested cmdlet
    Show-UntestedWarning

    try {
        
        # Retrieving authentication token
        Get-AuthToken($Account)

        if ($UpdateName) {

            # Setting variables needed to execute this function
            [xml]$XMLBody = '<?xml version="1.0" encoding="UTF-8"?>
                <server
                    xmlns="http://docs.openstack.org/compute/api/v1.1"
                    name="'+$UpdateName+'"/>'

            $URI = (Get-CloudURI("servers")) + "/servers/$CloudServerID"

            Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $XMLBody -ContentType application/xml -Method Put -ErrorAction Stop | Out-Null
            Write-Host "Your Cloud Server has been updated. Please wait 10 seconds for a refreshed Cloud Server list."

            Sleep 10

            Get-CloudServers -Account $account
        }
        elseif ($UpdateIPv4Address) {
            [xml]$XMLBody = '<?xml version="1.0" encoding="UTF-8"?>
                <server
                    xmlns="http://docs.openstack.org/compute/api/v1.1"
                    accessIPv4="'+$UpdateIPv4Address+'"
                />'
            
            $URI = (Get-CloudURI("servers")) + "/servers/$CloudServerID"

            Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $XMLBody -ContentType application/xml -Method Post -ErrorAction Stop | Out-Null
            Write-Host "Your Cloud Server has been updated. Please wait 10 seconds for a refreshed Cloud Server list."
            Sleep 10
            Get-CloudServers -Account $account
        }
        elseif ($UpdateIPv6Address) {

            # Setting variables needed to execute this function
            [xml]$XMLBody = '<?xml version="1.0" encoding="UTF-8"?>
                <server
                    xmlns="http://docs.openstack.org/compute/api/v1.1"
                    accessIPv6="'+$UpdateIPv6Address+'"
                />'
    
            $URI = (Get-CloudURI("servers")) + "/servers/$CloudServerID"

            Invoke-RestMethod -Uri URI -Headers $HeaderDictionary -Body $XMLBody -ContentType application/xml -Method Post -ErrorAction Stop | Out-Null
            Write-Host "Your Cloud Server has been updated. Please wait 10 seconds for a refreshed Cloud Server list."
            Sleep 10
            Get-CloudServers -Account $account
        }
        elseif ($UpdateAdminPassword) {
    
            # Setting variables needed to execute this function
            [xml]$XMLBody = '<?xml version="1.0" encoding="UTF-8"?>
                <changePassword
                xmlns="http://docs.openstack.org/compute/api/v1.1"
                adminPass="'+$UpdateAdminPassword+'"/>'

            $URI = (Get-CloudURI("servers")) + "/servers/$CloudServerID/action"

            Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $XMLBody -ContentType application/xml -Method Post -ErrorAction Stop
            Write-Host "Your Cloud Server has been updated."
        }
    }
    catch {
        Invoke-Exception($_.Exception)
    }
 
<#
 .SYNOPSIS
 This command will update the name, IPv4/IPv6 address, and/or the administrative/root password of your Rackspace Cloud Server.

 .DESCRIPTION
 Using this command, you will be able to update: 
 
 1) The name of the Cloud Server
 2) The IPv4/IPv6 address
 3) The administrative/root password
 
 The usage of the command would look like this "Update-CloudServer -Switch NewValue".

 .PARAMETER UpdateName
 Using this switch would indicate that you would like to change the name of your Rackspace Cloud server.

 .PARAMETER UpdateIPv4Address
 Using this switch would indicate that you would like to change the IPv4 address of your Rackspace Cloud server.

 .PARAMETER UpdateIPv6Address
 Using this switch would indicate that you would like to change the IPv6 address of your Rackspace Cloud server.

 .PARAMETER UpdateAdminPassword
 Using this switch would indicate that you would like to change the adminitrative/root password within your Rackspace Cloud Server.

 .PARAMETER CloudServerID
 This field is meant to be the 32 character identifier of your Rackspace Cloud Server.  If you need to figure out the ID, run the "Get-CloudServers" command to retrieve a full list of servers and their IDs from your account.

 
 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against.  Valid choices are defined in Conf.xml

 .EXAMPLE
 PS C:\Users\Administrator> Update-CloudServer -Account prod -CloudServerID abc123ef-9876-abcd-1234-123456abcdef  -UpdateName  New-Windows-Web-Server
 This example shows the command to rename a Rackspace Cloud Server with an ID of "abc123ef-9876-abcd-1234-123456abcdef" to a new name of "New-Windows-Web-Server".

  .EXAMPLE
 PS C:\Users\Administrator> Update-CloudServer -Account prod -CloudServerID abc123ef-9876-abcd-1234-123456abcdef  -UpdateAdminPassword NewC0mplexPassw0rd!
 This example shows the command to update the adminsitrative password of a Rackspace Cloud Server with an ID of "abc123ef-9876-abcd-1234-123456abcdef" to a new password of "NewC0mplexPassw0rd!".

 .LINK
 http://docs.rackspace.com/servers/api/v2/cs-devguide/content/ServerUpdate.html

#>
}

function Restart-CloudServer {

    Param(
        [Parameter(Position=0,Mandatory=$true)][string]$ServerID = $(throw "Please specify server ID with -ServerID parameter"),
        [Parameter(Position=2, Mandatory=$true)][string]$Account = $(throw "Please specify required Cloud Account with -Account parameter"),
        [Parameter(Position=3,Mandatory=$false)][string]$RegionOverride,
        [Parameter(Position=2,Mandatory=$False)][switch]$Hard
    )

    # Retrieving authentication token
    Get-AuthToken($Account)
    
    $URI = (Get-CloudURI("servers")) + "/servers/$ServerID/action"
    
    if($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

    if($Hard){
        $RebootType = "HARD"
    }
    else {
        $RebootType = "SOFT"
    }

    # Build our JSON object
    #
    $object = New-Object -TypeName PSCustomObject -Property @{
        "reboot"=New-Object -TypeName PSCustomObject -Property @{
            "type" = "$RebootType"
        }
    }

    $JSONbody = $object | ConvertTo-Json -Depth 2
    
    Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $JSONbody -ContentType application/json -Method Post -ErrorAction Stop
    
<#
 .SYNOPSIS
 The Restart-CloudServer cmdlet will carry out a soft reboot of the specified cloud server.

 .DESCRIPTION
 See synopsis.

 .PARAMETER ServerID
 Use this parameter to indicate the 32 character UUID of the cloud server of which you want to reboot. If you need to find this information, you can run the "Get-CloudServers" cmdlet for a complete listing of servers.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file. 
 Please note that this switch is not supported for UK Cloud accounts

 .PARAMETER Hard
 Use this switch to indicate that you would like the server be hard rebooted, as opposed to the default of a soft reboot.

 .EXAMPLE
 PS C:\Users\Administrator> Restart-CloudServer  -ServerID abc123ef-9876-abcd-1234-123456abcdef -account prod
 This example shows how to request a soft reboot of cloud server, UUID of abc123ef-9876-abcd-1234-123456abcdef, in the lon region.

 .EXAMPLE
 PS C:\Users\Administrator> Restart-CloudServer  -ServerID abc123ef-9876-abcd-1234-123456abcdef -account prod -Hard
 This example shows how to request a hard reboot of cloud server, UUID of abc123ef-9876-abcd-1234-123456abcdef, in the lon region.

 .LINK
 http://docs.rackspace.com/servers/api/v2/cs-devguide/content/Reboot_Server-d1e3371.html

#>    
 }

<#
function Resize-CloudServer {

    Param(
        [Parameter(Mandatory=$False)][switch]$Confirm,
        [Parameter(Mandatory=$False)][switch]$Revert,
        [Parameter(Mandatory=$true)][string]$CloudServerID = $(throw "Please specify server ID with -CloudServerID parameter"),
        [Parameter(Mandatory=$true)][string]$Account = $(throw "Please specify required Cloud Account with -Account parameter"),
        [Parameter(Mandatory=$False)][int]$CloudServerFlavorID
    )

    #
    #
    #
    # Missing logic - cmdlet incomplete!
    #
    # Show warning to identify untested cmdlet
    Show-UntestedWarning


    try {
        
        Write-Host "`nWarnming: This cmdlet and corresponding API call are deprecated.`n" -ForegroundColor Yellow

        throw "This function is not implemented yet!" 

        # Retrieving authentication token
        Get-AuthToken($Account)

        $URI = (Get-CloudURI("servers")) + "/servers/$CloudServerID/action"


        if ($Confirm) {
            $XMLBody = '<?xml version="1.0" encoding="UTF-8"?>
                <confirmResize
                xmlns="http://docs.openstack.org/compute/api/v1.1"/>'

            Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $XMLBody -ContentType application/xml -Method Post -ErrorAction Stop
            Write-Host "The resize action of your server has been confirmed."
        }
        elseif ($Revert) {
            $XMLBody = '<?xml version="1.0" encoding="UTF-8"?>
                <revertResize
                xmlns="http://docs.openstack.org/compute/api/v1.1"/>'

            Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $XMLBody -ContentType application/xml -Method Post -ErrorAction Stop
            Write-Host "Revert to previous size/ste has been initiated."
        }
        else {
            $XMLBody = '<?xml version="1.0" encoding="UTF-8"?>
                <resize
                xmlns="http://docs.openstack.org/compute/api/v1.1"/>'
            


            Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $XMLBody -ContentType application/xml -Method Post -ErrorAction Stop
            Write-Host "Resize process has been initiated."

        }
	}
    catch {
        Invoke-Exception($_.Exception)
    }

<#
 .SYNOPSIS
 The Resize-CloudServer cmdlet will resize the specified cloud server to a new flavor.  After the original request, you can also use this command to either REVERT your changes, or CONFIRM them.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudServerID
 Use this parameter to indicate the 32 character UUID of the cloud server which you want to resize. If you need to find this information, you can run the "Get-CloudServers" cmdlet for a complete listing of servers.

 .PARAMETER Account
 Use this parameter to indicate the account number for which you would like to execute this request.

 .PARAMETER CloudServerFlavorID
 Use this parameter to define the ID of the flavor that you would like to resize to for the server specified.  If you are unsure of which flavor to use, run the "Get-CloudServerFlavors" command.

 .PARAMETER Confirm
 Use this switch to indicate that you would like to confirm the requested resize be fully applied after testing your cloud server.  You should only use the confirm switch after the original request to resize the server and have verified everything is working as expected.

 .PARAMETER Revert
 Use this switch to indicate that you would like to revert the newly resized server to its previous state.  This will permanently undo the original resize operation.

 .EXAMPLE
 PS C:\Users\Administrator> Resize-CloudServer  -CloudServerID abc123ef-9876-abcd-1234-123456abcdef -Region lon -CloudServerFlavorID 3
 This example shows how to resize a server, UUID of abc123ef-9876-abcd-1234-123456abcdef, in the lon region, to a new size of 1GB RAM, 1 vCPU, 40GB storage.

 .EXAMPLE
 PS C:\Users\Administrator> Resize-CloudServer  -CloudServerID abc123ef-9876-abcd-1234-123456abcdef -Region ORD -Confirm
 This example shows how to confirm the resizing of a server, UUID of abc123ef-9876-abcd-1234-123456abcdef, in the ORD region.

 .EXAMPLE
 PS C:\Users\Administrator> Resize-CloudServer  -CloudServerID abc123ef-9876-abcd-1234-123456abcdef -Region ORD -Revert
 This example shows how to revert the resizing of a server, UUID of abc123ef-9876-abcd-1234-123456abcdef, in the ORD region, back to its previous size.

 .LINK
 http://docs.rackspace.com/servers/api/v2/cs-devguide/content/Resize_Server-d1e3707.html

#>
#}
#>

function Remove-CloudServer { 

    Param(
        [Parameter(Position=0,Mandatory=$true)][string]$ServerID = $(throw "Please specify server ID with -ServerID parameter"),
        [Parameter(Position=1, Mandatory=$true)][string]$Account = $(throw "Please specify required Cloud Account with -Account parameter"),
        [Parameter(Position=2,Mandatory=$false)][string]$RegionOverride
        )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

    Get-AuthToken($Account)
    $URI = (Get-CloudURI("servers")) + "/servers/$ServerID"

    Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Method Delete -ErrorAction Stop

    if (!$?) {
        break;
    }
    else {
        Write-Verbose "Your server has been scheduled for deletion. This action will take up to a minute to complete."
    }

<#
 .SYNOPSIS
 The Remove-CloudServer cmdlet will permanently delete a cloud server from your account.

 .DESCRIPTION
 See synopsis.

 .PARAMETER ServerID
 Use this parameter to indicate the 32 character UUID of the cloud server that you would like to delete. If you need to find this information, you can run the "Get-CloudServers" cmdlet for a complete listing of servers.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file. 
 Please note that this switch is not supported for UK Cloud accounts

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudServer  -CloudServerID abc123ef-9876-abcd-1234-123456abcdef -Account prod
 This example shows how to delete a server, UUID of abc123ef-9876-abcd-1234-123456abcdef, from the account prod

 
 .LINK
 http://docs.rackspace.com/servers/api/v2/cs-devguide/content/Delete_Server-d1e2883.html

#>
}

function Remove-CloudServerImage {

    Param(
        [Parameter(Position=0,Mandatory=$true)][string]$ServerImageID = $(throw "Please specify image ID with -ServerImageID parameter"),
        [Parameter(Position=1, Mandatory=$true)][string]$Account = $(throw "Please specify required Cloud Account with -Account parameter"),
        [Parameter(Position=2,Mandatory=$false)][string]$RegionOverride
        )

    # Retrieving authentication token
    Get-AuthToken($Account)

    $URI = (Get-CloudURI("servers")) + "/images/$ServerImageID"

    Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Method Delete -ErrorAction Stop
    Write-Host "Your Rackspace Cloud Server Image has been deleted."

<#
 .SYNOPSIS
 The Remove-CloudServerImage cmdlet will permanently delete a cloud server image snapshot from your account.

 .DESCRIPTION
 See synopsis.

 .PARAMETER ServerImageID
 Use this parameter to define the ID of the image that you would like to delete. If you are unsure of the image ID, run the "Get-CloudServerImages" command.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file. 
 Please note that this switch is not supported for UK Cloud accounts

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudServerImage  -CloudServerImageID abc123ef-9876-abcd-1234-123456abcdef -Region lon 
 This example shows how to delete a server image snapshot, UUID of abc123ef-9876-abcd-1234-123456abcdef, from the lon region.

 .EXAMPLE
 PS C:\Users\Administrator> Restart-CloudServerImage  abc123ef-9876-abcd-1234-123456abcdef ORD
 This example shows how to delete a server image snapshot, UUID of abc123ef-9876-abcd-1234-123456abcdef, from the ORD region, without using the parameter names.

 .LINK
 http://docs.rackspace.com/servers/api/v2/cs-devguide/content/Delete_Image-d1e4957.html

#>
}

function Set-CloudServerRescueMode {
    
    Param(
        [Parameter(Position=0,Mandatory=$true)][string]$CloudServerID = $(throw "Please specify server ID with -CloudServerID parameter"),
        [Parameter(Position=1, Mandatory=$true)][string]$Account = $(throw "Please specify required Cloud Account with -Account parameter"),
        [Parameter(Position=2,Mandatory=$false)][string]$RegionOverride,
        [Parameter(Position=2,Mandatory=$false)][switch]$Unrescue
    )

    # Show warning to identify untested cmdlet
    Show-UntestedWarning

    # Retrieving authentication token
    Get-AuthToken($Account)

    $URI = (Get-CloudURI("servers")) + "/servers/$CloudServerID/action"

    if ($Unrescue) {
        [xml]$XMLBody = '<?xml version="1.0" encoding="UTF-8"?>
        <unrescue xmlns="http://docs.rackspacecloud.com/servers/api/v1.1" />'
    
        $RescueMode = Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $XMLBody -ContentType application/xml -Method Post -ErrorAction Stop
        Write-Host "Your server is being restored to normal service. `nPlease wait for the status of the server to show ACTIVE before carrying out any further commands against it."
    }
    else {
        [xml]$XMLBody = '<?xml version="1.0" encoding="UTF-8"?>
        <rescue xmlns="http://docs.openstack.org/compute/ext/rescue/api/v1.1" />'
        
        $RescueModePass = (Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $XMLBody -ContentType application/xml -Method Post -ErrorAction Stop).adminPass
    
        Write-Host "Rescue Mode takes 5 - 10 minutes to enable. 
                    `nPlease do not interact with this server again until it's status is RESCUE.
                    `nYour temporary password in rescue mode is: $RescueModePass"
    }
}