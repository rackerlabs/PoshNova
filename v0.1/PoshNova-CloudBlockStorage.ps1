<############################################################################################


                           ___          _         __                
                          / _ \___  ___| |__   /\ \ \_____   ____ _ 
                         / /_)/ _ \/ __| '_ \ /  \/ / _ \ \ / / _` |
                        / ___/ (_) \__ \ | | / /\  / (_) \ V / (_| |
                        \/    \___/|___/_| |_\_\ \/ \___/ \_/ \__,_|
                                                 Cloud Block Storage

Authors
-----------
    Nielsen Pierce (nielsen.pierce@rackspace.co.uk)
    Alexei Andreyev (alexei.andreyev@rackspace.co.uk)
    
Description
-----------
PowerShell v3 module for interaction with NextGen Rackspace Cloud API (PoshNova) 


CBS API reference
---------------------------
http://docs.rackspace.com/cbs/api/v1.0/cbs-devguide/content/index.html

############################################################################################>

function Get-CloudBlockStorageTypes {

    Param(
        [Parameter (Position=0, Mandatory=$True)][string]$Account = $(throw "Please specify required Cloud Account with -account parameter"),
        [Parameter (Position=1, Mandatory=$False)][string]$RegionOverride
    )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

    # Retrieving authentication token
    Get-AuthToken($account)
    
    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("blockstorage")) + "/types.xml"
    
    ## Making the call to the API for a list of available volumes and storing data into a variable
    [xml]$VolTypeList = (Invoke-RestMethod -Uri $URI  -Headers $HeaderDictionary -ErrorAction Stop).innerxml
    
    return $VolTypeList.volume_types.volume_type

<#
 .SYNOPSIS
 Retrieve a list of all available cloud block storage volume types.

 .DESCRIPTION
 The Get-CloudBlockStorageTypes cmdlet will retrieve a list of all cloud block storage volume types, which will include the volume type ID and name.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file. 
 Please note that this switch is not supported for UK Cloud accounts

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudBlockStorageTypes -Account prod 
 This example shows how to list all cloud block storage volumes in the account prod.

  PS C:\> Get-CloudBlockStorageTypes -Account prod

  id                                      name                                    extra_specs
  --                                      ----                                    -----------
  1fd376b5-c84e-43c5-a66b-d895cb75ac2c    SATA
  58bea711-cb3e-4c04-a051-c8abc20d8fcc    SSD

 .LINK
 http://docs.rackspace.com/cbs/api/v1.0/cbs-devguide/content/GET_getVolumeTypes_v1__tenant_id__types_v1__tenant_id__types.html

#>
}

function Get-CloudBlockStorageVolList {

    Param(
        [Parameter (Position=0, Mandatory=$True)][string]$Account = $(throw "Please specify required Cloud Account with -account parameter"),
        [Parameter (Position=1, Mandatory=$False)][string]$RegionOverride
    )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

    # Retrieving authentication token
    Get-AuthToken($account)
    
    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("blockstorage")) + "/volumes.xml"
    
    # Making the call to the API for a list of available volumes and storing data into a variable
    [xml]$VolList = (Invoke-RestMethod -Uri $URI  -Headers $HeaderDictionary -ErrorAction Stop).innerxml
    
    if (!$VolList.volumes.volume){
        Write-Host "`nNo Cloud Block storage volumes found in this `n" -ForegroundColor Magenta
    }
    else {
        return $VolList.volumes.volume
    }

<#
 .SYNOPSIS
 Retrieve a list of all cloud block storage volumes for the specified region.

 .DESCRIPTION
 The Get-CloudBlockStorageVolList cmdlet will retrieve a list of all cloud block storage volumes in a given region.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file. 
 Please note that this switch is not supported for UK Cloud accounts

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudBlockStorageVolList -Account prod
 This example shows how to list all cloud block storage volumes in the account prod.

 .LINK
 http://docs.rackspace.com/cbs/api/v1.0/cbs-devguide/content/GET_getVolumesSimple__v1__tenant_id__volumes.html
#>
}

function Get-CloudBlockStorageVol {

    Param(
        [Parameter (Position=0, Mandatory=$true)][string]$VolID = $(throw "Please specify Volume ID with -VolID parameter"),
        [Parameter (Position=1, Mandatory=$True)][string]$Account = $(throw "Please specify required Cloud Account with -account parameter"),
        [Parameter (Position=2, Mandatory=$False)][string]$RegionOverride
    )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

    # Retrieving authentication token
    Get-AuthToken($account)
    
    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("blockstorage")) + "/volumes/$VolID"
    
    # Making the call to the API for a list of available volumes and storing data into a variable
    $VolList = (Invoke-RestMethod -Uri $URI  -Headers $HeaderDictionary -ErrorAction Stop)
    
    # Since the response body is XML, we can use dot notation to show the information needed without further parsing.
    return $VolList.volume
    
<#
 .SYNOPSIS
 Retrieve a list of all attributes for a given cloud block storage volume.

 .DESCRIPTION
 The Get-CloudBlockStorageVol cmdlet will retrieve a list of all attributes for a provided cloud block storage volume.

 .PARAMETER VolID
 Use this parameter to define the ID of the cloud block storage volume that you would like to query.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file. 
 Please note that this switch is not supported for UK Cloud accounts

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudBlockStorageVol -CloudBlockStorageVolID 216fdfab-1234-4963-aa11-6dd004ce0301 -Account prod
 This example shows how to list details for a cloud block storage volume in the account prod.

 .LINK
 http://docs.rackspace.com/cbs/api/v1.0/cbs-devguide/content/GET_getVolume__v1__tenant_id__volumes.html

#>
}

function Add-CloudBlockStorageVol {

    Param(
        [Parameter (Position=0, Mandatory=$true)][string] $VolName = $(throw "Please specify volume name with -VolName parameter"),
        [Parameter (Position=1, Mandatory=$false)][string] $VolDesc,
        [Parameter (Position=2, Mandatory=$true)][int] $VolSize = $(throw "Please specify volume size in GB with -VolSize parameter"),
        [Parameter (Position=3, Mandatory=$true)][string] $VolType = $(throw "Please specify volume type with -VolType parameter"),
        [Parameter (Position=4, Mandatory=$True)][string]$Account = $(throw "Please specify required Cloud Account with -account parameter"),
        [Parameter (Position=5, Mandatory=$False)][string]$RegionOverride
    )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

    Get-AuthToken($account)
    
    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("blockstorage")) + "/volumes.xml"

    if ($VolType -notlike "SATA"){
        if ($VolType -notlike "SSD") {
            throw "Volume type can be either SSD or SATA"
        }
    }

    if ($VolSize -lt 100 -or $VolSize -gt 1024) {
        throw "You must enter a volume size in GB from 100 to 1024"
    }

    # Create XML request
    [xml]$XMLBody = '<?xml version="1.0" encoding="UTF-8"?>
        <volume xmlns="http://docs.rackspace.com/volume/api/v1"
        display_name="'+$VolName+'"
        display_description="'+$VolDesc+'"
        size="'+$VolSize+'"
        volume_type="'+$VolType+'">
    </volume>'

    [xml]$NewVol = (Invoke-RestMethod -Uri $URI  -Headers $HeaderDictionary -Body $XMLBody -ContentType application/xml -Method Post -ErrorAction Stop).innerxml
    $NewVol.volume

<#
 .SYNOPSIS
 The Add-CloudBlockStorageVol cmdlet will add a cloud block storage volume.

 .DESCRIPTION
 See synopsis.

  .PARAMETER VolName
 Use this parameter to define the name of the volume you are about to make.

 .PARAMETER VolDesc
 Use this parameter to define the description of the volume you are about to make.

 .PARAMETER VolSize
 Use this parameter to define the size of the volume you are about to make. This must be between 100 and 1024.

 .PARAMETER VolType
 Use this parameter to define the type of the volume you are about to make. If you are unsure of what to enter, please run the Get-CloudBlockStorageTypes cmdlet to get valid parameter entries.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file. 
 Please note that this switch is not supported for UK Cloud accounts

 .EXAMPLE
 PS C:\Users\Administrator> Add-CloudBlockStorageVol -VolName Test2 -VolDesc "another backupt test" -VolSize 150 -VolType SATA -Account prod
 This example shows how to add a cloud block storage volume in the account prod

 .LINK
 http://docs.rackspace.com/cbs/api/v1.0/cbs-devguide/content/POST_createVolume_v1__tenant_id__volumes_v1__tenant_id__volumes.html

#>
}

function Remove-CloudBlockStorageVol {

    Param(
        [Parameter (Position=0, Mandatory=$true)][string]$VolID = $(throw "Please specify Volume ID with -VolID parameter"),
        [Parameter (Position=1, Mandatory=$True)][string]$Account = $(throw "Please specify required Cloud Account with -account parameter"),
        [Parameter (Position=2, Mandatory=$False)][string]$RegionOverride
    )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

    try {
        # Retrieving authentication token
        Get-AuthToken($account)
    
        # Setting variables needed to execute this function
        $URI = (Get-CloudURI("blockstorage")) + "/volumes/$VolID.xml"

        # Making the call to the API for a list of available volumes and storing data into a variable
        Invoke-RestMethod -Uri $URI  -Headers $HeaderDictionary -Method Delete -ErrorAction Stop

        Write-Host "`nThe volume has been deleted.`n" -ForegroundColor Magenta

	}
    catch {
        Invoke-Exception($_.Exception)
    }
    
<#
 .SYNOPSIS
 Remove a Cloud Block Storage volume.

 .DESCRIPTION
 The Remove-CloudBlockStorageVol cmdlet will remove a cloud block storage volume, that has been identified using its unique Volume ID.

 .PARAMETER VolID
 Use this parameter to define the ID of the cloud block storage volume that you would like to remove.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file. 
 Please note that this switch is not supported for UK Cloud accounts

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudBlockStorageVol  -VolID 5ea333b3-cdf7-40ee-af60-9caf871b15fa -Account prod
 This example shows how to remove a cloud block storage volume from the account prod

 .LINK
 http://docs.rackspace.com/cbs/api/v1.0/cbs-devguide/content/DELETE_deleteVolume_v1__tenant_id__volumes__volume_id__v1__tenant_id__volumes.html

#>
}

function Get-CloudBlockStorageSnapList {

    Param(
        [Parameter (Position=0, Mandatory=$True)][string]$Account = $(throw "Please specify required Cloud Account with -account parameter"),
        [Parameter (Position=1, Mandatory=$False)][string]$RegionOverride
    )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

    Get-AuthToken($account)
    
    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("blockstorage")) + "/snapshots"
    
    # Making the call to the API for a list of available volumes and storing data into a variable
    $VolSnapList = (Invoke-RestMethod -Uri $URI  -Headers $HeaderDictionary -ErrorAction Stop)
    
    if(!$VolSnapList.snapshots){
        Write-host "`nNo snapshots found in this region`n" -ForegroundColor Magenta
    }
    else {
        $VolSnapList.snapshots
    }

<#
 .SYNOPSIS
 Retrieve a list of Cloud Block Storage snapshots.

 .DESCRIPTION
 The Get-CloudBlockStorageSnapList cmdlet will retrieve a list of all snapshots for a provided cloud account.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file. 
 Please note that this switch is not supported for UK Cloud accounts

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudBlockStorageSnapList -Account prod
 This example shows how to list all cloud block storage snapshots in the account prod

 .LINK
 http://docs.rackspace.com/cbs/api/v1.0/cbs-devguide/content/GET_getSnapshotsSimple_v1__tenant_id__snapshots_v1__tenant_id__snapshots.html

#>
}

function Get-CloudBlockStorageSnap {

    Param(
        [Parameter (Position=0, Mandatory=$true)][string]$SnapID = $(throw "Please specify Volume ID with -SnapID parameter"),
        [Parameter (Position=1, Mandatory=$True)][string]$Account = $(throw "Please specify required Cloud Account with -account parameter"),
        [Parameter (Position=2, Mandatory=$False)][string]$RegionOverride
    )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

    Get-AuthToken($account)
    
    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("blockstorage")) + "/snapshots/$SnapID"
    
    
    # Making the call to the API for a list of available volumes and storing data into a variable
    $VolSnapDetails = (Invoke-RestMethod -Uri $URI  -Headers $HeaderDictionary)
    
    return $VolSnapDetails.snapshot
    
<#
 .SYNOPSIS
 Retrieve Cloud block Storage Snapshop details.

 .DESCRIPTION
 The Get-CloudBlockStorageSnap cmdlet will retrieve a list of all attributes for a provided cloud block storage snapshot.

 .PARAMETER SnapID
 Use this parameter to define the ID of the cloud block storage snapshot that you would like to query.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file. 
 Please note that this switch is not supported for UK Cloud accounts

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudBlockStorageSnap -CloudBlockStorageSnapID 5ea333b3-cdf7-40ee-af60-9caf871b15fa -account prod
 This example shows how to list details for a cloud block storage snapshot in the account prod.


 .LINK
 http://docs.rackspace.com/cbs/api/v1.0/cbs-devguide/content/GET_getSnapshot_v1__tenant_id__snapshots__snapshot_id__v1__tenant_id__snapshots.html

#>
}

function Add-CloudBlockStorageSnap {

    Param(
        [Parameter (Position=0, Mandatory=$true)][string] $VolID = $(throw "Please specify Volume ID with -VolID parameter"),
        [Parameter (Position=1, Mandatory=$true)][string] $SnapName = $(throw "Please specify snapshot name with -SnapName parameter"),
        [Parameter (Position=2, Mandatory=$false)][string] $SnapDesc,
        [Parameter (Position=3, Mandatory=$true)][string] $Account = $(throw "Please specify cloud account with -Account parameter"),
        [Parameter (Position=4, Mandatory=$false)][switch] $Force,
        [Parameter (Position=5, Mandatory=$False)][string] $RegionOverride
    )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

    # Retrieving authentication token
    Get-AuthToken($account)
    
    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("blockstorage")) + "/snapshots.xml"
    
    # Force switch variable setting
    if ($force) {
        $ForceOut = "true"
    }
    else {
        $ForceOut = "false"
    }
    
    # Create XML request
    [xml]$XMLBody = '<?xml version="1.0" encoding="UTF-8"?>
        <snapshot xmlns="http://docs.rackspace.com/volume/api/v1"
        name="'+$SnapName+'"
        display_name="'+$SnapName+'"
        display_description="'+$SnapDesc+'"
        volume_id="'+$VolID+'"
        force="'+$ForceOut+'" />'
    
    [xml]$VolSnap = (Invoke-RestMethod -Uri $URI  -Headers $HeaderDictionary -Body $XMLBody -ContentType application/xml -Method Post -ErrorAction Stop).innerxml
    $VolSnap.snapshot

<#
 .SYNOPSIS
 Create a snapshot of a block storage volume.

 .DESCRIPTION
 The Add-CloudBlockStorageSnap cmdlet will create a snapshot of a defined cloud block storage volume.

 .PARAMETER VolID
 Use this parameter to define the ID of the cloud block storage volume that you would like to snapshot.

 .PARAMETER SnapName
 Use this parameter to define the name of the snapshot you are about to take.

 .PARAMETER SnapDesc
 Use this parameter to define the description of the snapshot you are about to take.

 .PARAMETER Force
 Use this switch to indicate whether to snapshot the volume, even if the volume is attached and in use.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file. 
 Please note that this switch is not supported for UK Cloud accounts

 .EXAMPLE
 PS C:\Users\Administrator> Add-CloudBlockStorageSnap -CloudBlockStorageVolID 5ea333b3-cdf7-40ee-af60-9caf871b15fa -CloudBlockStorageSnapName Snapshot-Test -CloudBlockStorageSnapDesc "This is a test snapshot" -Account prod -Force
 This example shows how to add a cloud block storage snapshot in the account prod.

 .LINK
 http://docs.rackspace.com/cbs/api/v1.0/cbs-devguide/content/POST_createSnapshot_v1__tenant_id__snapshots_v1__tenant_id__snapshots.html

#>
}

function Remove-CloudBlockStorageSnap {

    Param(
        [Parameter (Position=0, Mandatory=$true)][string] $SnapID = $(throw "Please specify snapshot ID with -SnapID parameter"),
        [Parameter (Position=1, Mandatory=$True)][string]$Account = $(throw "Please specify required Cloud Account with -account parameter"),
        [Parameter (Position=2, Mandatory=$False)][string]$RegionOverride
    )

    Show-UntestedWarning

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

    # Retrieving authentication token
    Get-AuthToken($account)
    
    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("blockstorage")) + "/snapshots/$SnapID"
    
    # Making the call to the API for a list of available volumes and storing data into a variable
    $VolSnap = (Invoke-RestMethod -Uri $URI  -Headers $HeaderDictionary -Method Delete -ErrorAction Stop)
    
    Write-Host "`nThe snapshot has been deleted`n" -ForegroundColor Magenta

<#
 .SYNOPSIS
 Remove a cloud block storage snapshot.

 .DESCRIPTION
 The Remove-CloudBlockStorageSnap cmdlet will remove a cloud block storage snapshot.

 .PARAMETER SnapID
 Use this parameter to define the ID of the cloud block storage snapshot that you would like to delete.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file. 
 Please note that this switch is not supported for UK Cloud accounts

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudBlockStorageSnap  -SnapID 5ea333b3-cdf7-40ee-af60-9caf871b15fa -Account prod
 This example shows how to remove a cloud block storage snapshot from the account prod.

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudBlockStorageSnap 5ea333b3-cdf7-40ee-af60-9caf871b15fa prod
 This example shows how to list details for a cloud block storage snapshot in the account prod, without parameter names.

 .LINK
 http://docs.rackspace.com/cbs/api/v1.0/cbs-devguide/content/DELETE_deleteSnapshot_v1__tenant_id__snapshots__snapshot_id__v1__tenant_id__snapshots.html

#>
}

function Mount-CloudBlockStorageVol {

    Param(
        [Parameter (Position=0, Mandatory=$true)][string] $ServerID = $(throw "Please specify required server ID with -ServerID parameter"),
        [Parameter (Position=1, Mandatory=$true)][string] $VolID = $(throw "Please specify Volume ID with -VolID parameter"),
        [Parameter (Position=2, Mandatory=$True)][string] $Account = $(throw "Please specify required Cloud Account with -account parameter"),
        [Parameter (Position=3, Mandatory=$False)][string] $RegionOverride
    )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

    Get-AuthToken($account)
    
    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("servers")) + "/servers/$ServerID/os-volume_attachments.xml"
    
    [xml]$XMLBody = '<?xml version="1.0" encoding="UTF-8"?>
        <volumeAttachment
        xmlns="http://docs.openstack.org/compute/api/v1.1"
        volumeId="'+$VolID+'"/>'
     
    $result = (Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $XMLBody -ContentType application/xml -Method Post -ErrorAction Stop).innerxml
    
    Write-Host "`nConnecting volume process has been initiated.`n"  -ForegroundColor Magenta

<#
 .SYNOPSIS
 Attach a cloud block storage volume to a server.

 .DESCRIPTION
 The Connect-CloudBlockStorageVol cmdlet will attach a cloud block storage volume to a cloud server.

 .PARAMETER ServerID
 Use this parameter to indicate the ID of the cloud server to which you wish to attach storage volume.

 .PARAMETER VolID
 Use this parameter to define the ID of the cloud block storage volume that you would like to query.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file. 
 Please note that this switch is not supported for UK Cloud accounts

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudBlockStorageSnap  -SnapID 5ea333b3-cdf7-40ee-af60-9caf871b15fa -Account prod
 This example shows how to remove a cloud block storage snapshot from the account prod.

 .LINK
 http://docs.rackspace.com/servers/api/v2/cs-devguide/content/Attach_Volume_to_Server.html
#>
}

function Dismount-CloudBlockStorageVol {

        Param(
        [Parameter (Position=0, Mandatory=$true)][string] $ServerID = $(throw "Please specify required server ID with -ServerID parameter"),
        [Parameter (Position=1, Mandatory=$true)][string] $VolID = $(throw "Please specify Volume ID with -VolID parameter"),
        [Parameter (Position=2, Mandatory=$True)][string] $Account = $(throw "Please specify required Cloud Account with -account parameter"),
        [Parameter (Position=3, Mandatory=$False)][string]$RegionOverride
    )

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

    Get-AuthToken($account)
    
    # Setting variables needed to execute this function
    $URI = (Get-CloudURI("servers")) + "/servers/$ServerID/os-volume_attachments/$VolID.xml"
    
    Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Method Delete -ErrorAction Stop
    
    Write-Host "`nThe cloud block storage volume disconnection has been initiated.`n" -ForegroundColor Magenta
<#
 .SYNOPSIS
 

 .DESCRIPTION
 The Disconnect-CloudBlockStorageVol cmdlet will detach a cloud block storage volume from a cloud server.

 .PARAMETER ServerID
 Use this parameter to indicate the ID of the cloud server to which you wish to attach storage volume.

 .PARAMETER VolID
 Use this parameter to define the ID of the cloud block storage volume that you would like to query.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshNova configuration file. 
 Please note that this switch is not supported for UK Cloud accounts

 .EXAMPLE
 PS H:\> Disconnect-CloudBlockStorageVol -ServerID 46e81093-2000-4d3d-8d80-07cabe001297 -VolID 37aca46e-efeb-4c6d-88d9-7768cb01e112 -Account prod
 This example will detach the specified volume form the server in question for the prod account

 .LINK
 http://docs.rackspace.com/servers/api/v2/cs-devguide/content/Delete_Volume_Attachment.html

#>
}
