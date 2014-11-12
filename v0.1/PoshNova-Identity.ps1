<############################################################################################

                           ___          _         __                
                          / _ \___  ___| |__   /\ \ \_____   ____ _ 
                         / /_)/ _ \/ __| '_ \ /  \/ / _ \ \ / / _` |
                        / ___/ (_) \__ \ | | / /\  / (_) \ V / (_| |
                        \/    \___/|___/_| |_\_\ \/ \___/ \_/ \__,_|
                                                            Identity

Authors
-----------
    Nielsen Pierce (nielsen.pierce@rackspace.co.uk)
    Alexei Andreyev (alexei.andreyev@rackspace.co.uk)
    
Description
-----------
PowerShell v3 module for interaction with NextGen Rackspace Cloud API (PoshNova) 

Identity v2.0 API reference
---------------------------
http://docs.rackspace.com/auth/api/v2.0/auth-client-devguide/content/Overview-d1e65.html

############################################################################################>


<#
List of cmdlets missing or not working
-----------------------------
- Authenticate User - Implemented in Get-AuthToken(main module)
Get User Credentials - Currently-authenticated user details are already contained in $token
List Crendentials - these details are already in the $token variable
- Reset User Api Key - Reset-CloudIdentityUserApi #### Unsupported - need to test further ####
Revoke Token
#>

function Get-CloudIdentityUsers {
    param (
        [Parameter(Mandatory=$True)][string] $Account = $(throw "Please specify required Cloud Account with -Account parameter")
    )

    Get-AuthToken($account)

    $URI = (Get-CloudURI("identity")) + "users"

    #return (Invoke-RestMethod -Uri $URI  -Headers $HeaderDictionary -ErrorAction Stop).users
    $r = (Invoke-WebRequest -Uri $URI -Method GET -Headers $HeaderDictionary)|ConvertFrom-Json
	return $r.users

<#
 .SYNOPSIS
 Get a list of users on the account.

 .DESCRIPTION
 The Get-CloudIdentityUsers cmdlet will display a list of users on the cloud account together with extra details on each. 
 The list includes identifying information about each user. This will include the user's email account, username, user ID and status.
 
 Please note: If not using the admin role then the request will only dislay the current user.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .EXAMPLE
 PS C:\> Get-CloudIdentityUsers prod
 This example shows how to get a list of all networks currently deployed in the account prod

 .LINK
 http://docs.rackspace.com/auth/api/v2.0/auth-client-devguide/content/User_Calls.html
#>
}

function Get-CloudIdentityRoles {
    param (
        [Parameter(Mandatory=$True)][string] $Account = $(throw "Please specify required Cloud Account with -Account parameter")
    )

    Get-AuthToken($account)

    $URI = (Get-CloudURI("identity")) + "OS-KSADM/roles"

    (Invoke-RestMethod -Uri $URI  -Headers $HeaderDictionary -ErrorAction Stop).roles | Select-Object id,name,RAX-AUTH:Weight,RAX-AUTH:propagate,description

<#
 .SYNOPSIS
 Get a list of roles defined for the account.

 .DESCRIPTION
 The Get-CloudIdentityRoles cmdlet will display a list of roles on the cloud account together with extra details on each. 
 The list includes information about each role. This will include role id, name, wieght, propagation and description.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .EXAMPLE
 PS C:\> Get-CloudIdentityRoles prod
 This example shows how to get a list of all networks currently deployed for prod account.

 .LINK
 http://docs.rackspace.com/auth/api/v2.0/auth-client-devguide/content/GET_listRoles_v2.0_OS-KSADM_roles_Role_Calls.html
#>
}

function Get-CloudIdentityTenants {
    param (
        [Parameter(Mandatory=$True)][string] $Account = $(throw "Please specify required Cloud Account with -Account parameter")
    )

    Get-AuthToken($account)

    $URI = (Get-CloudURI("identity")) + "tenants"

    (Invoke-RestMethod -Uri $URI  -Headers $HeaderDictionary -ErrorAction Stop).tenants

<#
 .SYNOPSIS
 Get a list of tenants in an OpenStack deployment.

 .DESCRIPTION
 The Get-CloudIdentityTenants cmdlet will display a list of tenants on an OpenStack deployment. This is not really used on Rackspace Public cloud.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .EXAMPLE
 PS C:\> Get-CloudIdentityRoles prod
 
 .LINK
 http://docs.rackspace.com/auth/api/v2.0/auth-client-devguide/content/GET_listTenants_v2.0_tenants_Tenant_Calls.html
#>
}

function Get-CloudIdentityUser {
    param (
        [Parameter(Position=0,Mandatory=$False)][string] $UserID,
        [Parameter(Position=0,Mandatory=$False)][string] $UserName,
        [Parameter(Position=0,Mandatory=$False)][string] $UserEmail,
        [Parameter(Position=1,Mandatory=$True)][string] $Account = $(throw "Please specify required Cloud Account with -Account parameter")
    )

    Get-AuthToken($account)
    
    if ($UserID) {
        $URI = (Get-CloudURI("identity")) + "users/$UserID"
    }
    elseif ($UserName) {
        $URI = (Get-CloudURI("identity")) + "users?name=$UserName"
    }
    elseif ($UserEmail) {
        $URI = (Get-CloudURI("identity")) + "users?email=$UserEmail"
    }
    else {
        throw "You have to provide either UserID, UserName or UserEmail parameters"
    }

    $result = (Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -ErrorAction Stop)

    if ($UserID -or $UserName) {
        return $result.user
    }
    else {
        return $result.users
    }

<#
 .SYNOPSIS
 Get details of a single user, identified by ID, name or email.

 .DESCRIPTION
 The Get-CloudIdentityUser cmdlet will retrieve user details for a user, which can be identified by his/her ID, username or email address. 

 The details returned includes user ID, status, creation and update dates/times, default region and email address.

 .PARAMETER Account
 Use this mandatory parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER $UserID
 Use this optional parameter to identify user by his/her user ID you would like to specify. 

 .PARAMETER $UserName
 Use this optional parameter to identify user by his/her user name you would like to specify. 

 .PARAMETER $UserEmail
 Use this optional parameter to identify user by his/her email you would like to specify. 

 .EXAMPLE
 PS C:\> Get-CloudIdentityUser -UserName demouser -Account prod
 This example shows how to get details user demouser in prod account.

 .EXAMPLE
 PS C:\> Get-CloudIdentityUser -UserID 12345678 -Account prod
 This example shows how to get details user ID 12345678 in prod account.

 .EXAMPLE
 PS C:\> Get-CloudIdentityUser -UserEmail demouser@democorp.com -Account prod
 This example shows how to get details user with email 'demouser@democorp.com' in prod account.

 .LINK
 http://docs.rackspace.com/auth/api/v2.0/auth-client-devguide/content/User_Calls.html
#>
}

function Get-CloudIdentityUserRoles {
    param (
        [Parameter(Position=0,Mandatory=$True)][string] $UserID = $(throw "Specify the user ID with -UserID"),
        [Parameter(Position=1,Mandatory=$True)][string] $Account = $(throw "Please specify required Cloud Account with -Account parameter")
    )

    Get-AuthToken($account)

    $URI = (Get-CloudURI("identity")) + "users/$UserID/roles"

    (Invoke-RestMethod -Uri $URI  -Headers $HeaderDictionary -ErrorAction Stop).roles | Select-Object name,id,description

<#
 .SYNOPSIS
 Get a list roles which a specific user is asigned.

 .DESCRIPTION
 The Get-CloudIdentityUserRoles cmdlet will display a list of roles which a user is assigned.
 The list includes role id, name, , propagation and description.

 .PARAMETER Account
 Use this mandatory parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .PARAMETER $UserID
 Use this mandatory parameter to specify a user by his/her user ID. 

 .EXAMPLE
 PS C:\> Get-CloudIdentityUserRoles -UserID 12345678 -Account prod
 This example shows how to get a list of assigned roles for a specific user, identified by his/her user ID.

 .LINK
 http://docs.rackspace.com/auth/api/v2.0/auth-client-devguide/content/GET_listRoles_v2.0_OS-KSADM_roles_Role_Calls.html
#>
}

function Reset-CloudIdentityUserApi {
    param (
        [Parameter(Position=0,Mandatory=$True)][string] $UserID = $(throw "Specify the user ID with -UserID"),
        [Parameter(Position=1,Mandatory=$True)][string] $Account = $(throw "Please specify required Cloud Account with -Account parameter")
    )
    
    #######
    ####### This cmdlet does not work at this time
    #######

    Show-UntestedWarning

    Get-AuthToken($account)

    $URI = (Get-CloudURI("identity")) + "users/$UserID/OS-KSADM/credentials/RAX-KSKEY:apiKeyCredentials/RAX-AUTH/reset"

    Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Method Post -ErrorAction Stop
}

function New-CloudIdentityUser {
    param (
        [Parameter(Position=0,Mandatory=$True)][string] $UserName = $(throw "Specify the user name with -UserName"),
        [Parameter(Position=1,Mandatory=$True)][string] $UserEmail = $(throw "Specify the user's email with -UserEmail"),
        [Parameter(Position=2,Mandatory=$False)][string] $UserPass,
        [Parameter(Position=3,Mandatory=$False)][switch] $Disabled,
        [Parameter(Position=4,Mandatory=$True)][string] $Account = $(throw "Please specify required Cloud Account with -Account parameter")
    )

    Get-AuthToken($account)

    $URI = (Get-CloudURI("identity")) + "users"

    $object = New-Object -TypeName PSCustomObject -Property @{
        "user"=New-Object -TypeName PSCustomObject -Property @{
            "username"=$UserName;
            "email"=$UserEmail;
            "enabled"=(!$Disabled)
        }
    }

    if ($UserPass){
        Add-Member -InputObject $object.user -NotePropertyName "OS-KSADM:password" -NotePropertyValue $UserPass
    }

    $JSONbody = $object | ConvertTo-Json

    (Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $JSONbody -ContentType application/json -Method Post -ErrorAction Stop).user

<#
 .SYNOPSIS
 Create a new cloud user.

 .DESCRIPTION
 The New-CloudIdentityUser cmdlet will create a new user.
 The list includes role id, name, , propagation and description.

 .PARAMETER $UserName
 Use this mandatory parameter to specify a username for the new account. 

 .PARAMETER $UserEmail
 Use this mandatory parameter to specify an email address for the new account. 

 .PARAMETER $UserPass
 Use this parameter to specify a password for the new account. 
 If you do not specify this parameter, a secure password will be set for the user and will be included as part of the cmdlet output.

 .PARAMETER $Disabled
 Use this switch parameter to disable the account as soon as it is created.

 .PARAMETER Account
 Use this mandatory parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .EXAMPLE
 PS C:\> Get-CloudIdentityUserRoles -UserID 12345678 -Account prod
 This example shows how to get a list of assigned roles for a specific user, identified by his/her user ID.

 .LINK
 http://docs.rackspace.com/auth/api/v2.0/auth-client-devguide/content/User_Calls.html
#>
}

function Remove-CloudIdentityUser {
    param (
        [Parameter(Position=0,Mandatory=$True)][string] $UserID = $(throw "Specify the user ID with -UserID"),
        [Parameter(Position=1,Mandatory=$True)][string] $Account = $(throw "Please specify required Cloud Account with -Account parameter")
    )

    Get-AuthToken($account)

    $URI = (Get-CloudURI("identity")) + "users/$UserID"

    #Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Method Delete -ErrorAction Stop
    $r = (Invoke-WebRequest -Uri $URI -Method DELETE -Headers $HeaderDictionary)

}

function Edit-CloudIdentityUser {
    param (
        [Parameter(Position=0,Mandatory=$True)][string] $UserID = $(throw "Specify the user name with -UserID"),
        [Parameter(Position=1,Mandatory=$False)][string] $UserName,
        [Parameter(Position=2,Mandatory=$False)][string] $UserEmail,
        [Parameter(Position=3,Mandatory=$False)][string] $UserPass,
        [Parameter(Position=4,Mandatory=$False)] [ValidateSet("true","false")] [string] $Disabled,
        [Parameter(Position=5,Mandatory=$False)] [ValidateSet("LON","DFW","ORD","IAD","HKG","SYD")] [string] $UserRegion,
        [Parameter(Position=6,Mandatory=$True)][string] $Account = $(throw "Please specify required Cloud Account with -Account parameter")
    )

    Get-AuthToken($account)
    $URI = (Get-CloudURI("identity")) + "users/$UserID"

    $object = New-Object -TypeName PSCustomObject -Property @{
        "user"=New-Object -TypeName PSCustomObject -Property @{
        }
    }

    if ($UserName -or $UserEmail -or $UserPass -or $Disabled -or $UserRegion){
        if ($UserName){
            Add-Member -InputObject $object.user -NotePropertyName "username" -NotePropertyValue $UserName
        }
        if ($UserEmail){
            Add-Member -InputObject $object.user -NotePropertyName "email" -NotePropertyValue $UserEmail
        }
        if ($UserPass){
            Add-Member -InputObject $object.user -NotePropertyName "OS-KSADM:password" -NotePropertyValue $UserPass
        }
        if ($Disabled){
            switch ($Disabled) {
                True {
                    Add-Member -InputObject $object.user -NotePropertyName "enabled" -NotePropertyValue "false"
                }
                False {
                    Add-Member -InputObject $object.user -NotePropertyName "enabled" -NotePropertyValue "true"
                }
            }
        }
        if ($UserRegion){
            Add-Member -InputObject $object.user -NotePropertyName "RAX-AUTH:defaultRegion" -NotePropertyValue $UserRegion
        }
    }
    else {
        throw "Please provide the user property you wish to modify!"
    }

    $JSONbody = $object | ConvertTo-Json

    (Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $JSONbody -ContentType application/json -Method Post -ErrorAction Stop).user

<#
 .SYNOPSIS
 Edit an existing cloud user.

 .DESCRIPTION
 The Edit-CloudIdentityUser cmdlet will edit any attributes for an existing user, as supplied via the parameters.
 All optional parameters can be specified as part of the same command.

 .PARAMETER $UserID
 Use this mandatory parameter to identify the user you would like to edit.

 .PARAMETER $UserName
 Use this parameter to edit the username.

 .PARAMETER $UserEmail
 Use this parameter to edit an email address for the account. 

 .PARAMETER $UserPass
 Use this parameter to edit a password for and account. 

 .PARAMETER $Disabled
 Use this switch parameter to disable or enable a user account.

 .PARAMETER Account
 Use this mandatory parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .EXAMPLE
 PS C:\> Edit-CloudIdentityUser -UserID 12345678 -Account prod -UserName "new-user-name" -Disabled false
 This example shows how to change the username for a specific user at the same time as enabling it.

 .LINK
 http://docs.rackspace.com/auth/api/v2.0/auth-client-devguide/content/User_Calls.html
#>
}

function Add-CloudIdentityRoleForUser {
    param (
        [Parameter(Position=0,Mandatory=$True)][string] $UserID = $(throw "Specify the user ID with -UserID"),
        [Parameter(Position=1,Mandatory=$True)][string] $RoleID = $(throw "Specify the role ID with -RoleID"),
        [Parameter(Position=2,Mandatory=$True)][string] $Account = $(throw "Please specify required Cloud Account with -Account")
    )

    Get-AuthToken($account)
    $URI = (Get-CloudURI("identity")) + "users/$UserID/roles/OS-KSADM/$RoleID"


    Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Method Put -ErrorAction Stop

<#
 .SYNOPSIS
 Add role membership for a cloud user.

 .DESCRIPTION
 The Add-CloudIdentityRoleForUser cmdlet will add role membership for an existing cloud user.

 .PARAMETER $UserID
 Use this mandatory parameter to identify the user you would like to edit by his/her unique ID.

 .PARAMETER $RoleID
 Use this mandatory parameter used to specify the role ID. Use Get-CloudIdentityRoles to see a list of all available roles.

 .PARAMETER $Account
 Use this mandatory parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .EXAMPLE
 PS C:\> Add-CloudIdentityRoleForUser -UserID 12345678 -RoleID 12345678 -Account prod
 This example shows how to modify role assignment for a specific user.

 .LINK
 http://docs.rackspace.com/auth/api/v2.0/auth-client-devguide/content/User_Calls.html
#>
}

function Remove-CloudIdentityRoleForUser {
    param (
        [Parameter(Position=0,Mandatory=$True)][string] $UserID = $(throw "Specify the user ID with -UserID"),
        [Parameter(Position=1,Mandatory=$True)][string] $RoleID = $(throw "Specify the role ID with -RoleID"),
        [Parameter(Position=2,Mandatory=$True)][string] $Account = $(throw "Please specify required Cloud Account with -Account")
    )

    Get-AuthToken($account)
    $URI = (Get-CloudURI("identity")) + "users/$UserID/roles/OS-KSADM/$RoleID"


    Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Method Delete -ErrorAction Stop

<#
 .SYNOPSIS
 Remove role membership from a cloud user.

 .DESCRIPTION
 The Remove-CloudIdentityRoleForUser cmdlet will remove role membership for an existing cloud user.

 .PARAMETER $UserID
 Use this mandatory parameter to identify the user you would like to edit by his/her unique ID.

 .PARAMETER $RoleID
 Use this mandatory parameter used to specify the role ID. Use Get-CloudIdentityUserRoles to see a list of all currently-assigned roles for this user.

 .PARAMETER $Account
 Use this mandatory parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshNova configuration file.

 .EXAMPLE
 PS C:\> Remove-CloudIdentityRoleForUser -UserID 12345678 -RoleID 12345678 -Account prod
 This example shows how to modify role assignment for a specific user.

 .LINK
 http://docs.rackspace.com/auth/api/v2.0/auth-client-devguide/content/User_Calls.html
#>
}
