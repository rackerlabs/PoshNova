<############################################################################################

                           ___          _         __                
                          / _ \___  ___| |__   /\ \ \_____   ____ _ 
                         / /_)/ _ \/ __| '_ \ /  \/ / _ \ \ / / _` |
                        / ___/ (_) \__ \ | | / /\  / (_) \ V / (_| |
                        \/    \___/|___/_| |_\_\ \/ \___/ \_/ \__,_|
                                                       Master Module 
                                                         Version 0.1

Authors
-----------
    Nielsen Pierce (nielsen.pierce@rackspace.co.uk)
    Alexei Andreyev (alexei.andreyev@rackspace.co.uk)
    
Description
-----------
PowerShell v3 module for interaction with NextGen Rackspace Cloud API (PowerNova) 

This is a modification of Mitch Robin's original PowerClient module described at 
the below blog post:
http://developer.rackspace.com/blog/powerclient-rackspace-cloud-api-powershell-client.html


############################################################################################>

# Cloud account configuration file
#$Global:PowerNovaConfFile = $env:LOCALAPPDATA + "\PowerNova\CloudAccounts.csv"
$Global:PoshNovaConfFile = $env:USERPROFILE + "\Documents\WindowsPowerShell\Modules\PoshNova\CloudAccounts.csv" 

############################################################################################
#
# Shared cloud functions for use within module cmdlets. 
#
# This includes the central authentication cmdlets
#
############################################################################################

function Get-CloudAccount {
    <#
    Read $Global:PoshNovaConfFile then populate global account variables 
    based on value of $Global:account
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True)][string] $account = $(throw "Please specify required Cloud Account with -account parameter")
    )

    # Valid DC regions
    $ValidRegions = @("lon","ord","dfw","iad","hkg","syd")

    try {
        # Search $ConfigFile file for $account entry and populate temporary $conf with relevant details
        $Global:Credentials = Import-Csv $PoshNovaConfFile | Where-Object {$_.AccountName -eq $Account}
        
        # Raise exception if specified $account is not found in conf file
        if ($Credentials.AccountName -eq $null) {
            throw "Get-CloudAccount: `"$account`" account is not defined in the configuration file"
        }

        # Raise exception if specified DC is not supported
        if ($ValidRegions –notcontains $Credentials.Region) {
            $reg = $Credentials.Region
            throw "Get-CloudAccount: The `"$reg`" region specified in the configuration file is not valid"
        }
    }
    catch {
        Invoke-Exception($_.Exception)
    }

}

function Get-AuthToken {
    param (
        [Parameter(Mandatory=$True)][string] $Account = $(throw "Please specify required Cloud Account with -account parameter")
    )
    
    # Setting extra variables needed for function execution
    $AuthURI = "https://identity.api.rackspacecloud.com/v2.0/tokens.xml"

    # Check for current authentication token and retrieves a new one if needed
    if ($Account -ne $Credentials.AccountName -or (Get-Date) -ge $token.access.token.expires) {
        
        Get-CloudAccount($Account)

        $AuthBody = ('{
            "auth":{
                "RAX-KSKEY:apiKeyCredentials":{
                    "username":"'+$Global:Credentials.CloudUsername+'",
                    "apiKey":"'+$Global:Credentials.CloudAPIKey+'"
                }
            }
        }')

        # Making the call to the token authentication API and saving it's output as a global variable for reference in every other function.
        $Global:token = (Invoke-RestMethod -Uri $AuthURI -Body $AuthBody -ContentType application/json -Method Post  -ErrorAction Stop) 
        $CloudServerRegionList = ($token.access.serviceCatalog.service | Where-Object {$_.type -eq "compute"}).endpoint
        $FinalToken = $token.access.token.id

        <#
        Headers in powershell need to be defined as a dictionary object, so here we're creating 
        a dictionary object with the newly granted token. It's global, as it's needed in every future request.
        #>

        $global:HeaderDictionary = (new-object "System.Collections.Generic.Dictionary``2[[System.String, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089],[System.String, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]]")
        $HeaderDictionary.Add("X-Auth-Token", $finaltoken)
	}
}

function Get-CloudURI {
    <#
    Builds the first section of cloud API URI string based on the current 
    value of the provided service type parameter.

    It also makes use of the following global variables as defined in config file or provided by user in the case of $RegionOverride
        $Global:Region - Datacenter name
        $Global:RegionOverride - used in place of above if supplied
        $CloudDDI - Cloud Account number

    #>

    param (
        [Parameter(Mandatory=$True)]
            [ValidateSet(
                "servers",
                "loadbalancers",
                "blockstorage", 
                "identity",
                "autoscale",
                "monitoring"
            )] 
            [string] $ServiceName
    )

    try {
        

        # Check for existence of prerequisite global variables
        if ($Global:Credentials.Region -eq $null -or $Global:Credentials.CloudDDI -eq $null) {
            throw "The global cloud account variables are not fully loaded, please ensure that Get-CloudAcount has been executed"
        }
        elseif ($RegionOverride){
            if ($Credentials.region -like "lon"){
                # LON cloud accounts do not support multi-region deployment yet
                Remove-Variable -Name RegionOverride -Scope Global
                throw "-RegionOverride switch is not supported with LON accounts at this time"
            }
            else {
                $URIRegion = $Global:RegionOverride
                Remove-Variable -Name RegionOverride -Scope Global
            }
        }
        else{
            $URIRegion = $Credentials.region
        }

        switch ($ServiceName) {
            "servers" {
                $CloudURI = "https://" + $URIRegion + "." + $ServiceName + ".api.rackspacecloud.com/v2/" + $Credentials.CloudDDI
                break;
            }
            "identity" {
                $CloudURI = "https://" + $ServiceName + ".api.rackspacecloud.com/v2.0/"
                break;
            }
            "blockstorage" {
                $CloudURI = "https://" + $URIRegion + "." + $ServiceName + ".api.rackspacecloud.com/v1/" + $Credentials.CloudDDI
                break;
            }
            "loadbalancers" {
                $CloudURI = "https://" + $URIRegion + "." + $ServiceName + ".api.rackspacecloud.com/v1.0/" + $Credentials.CloudDDI
                break;
            }
            "autoscale" {
                $CloudURI = "https://" + $URIRegion + "." + $ServiceName + ".api.rackspacecloud.com/v1.0/" + $Credentials.CloudDDI
                break;
            }
            "monitoring" {
                $CloudURI = "https://" + $ServiceName + ".api.rackspacecloud.com/v1.0/" + $Credentials.CloudDDI
                break;
            }
            default {
                throw "Looks like something went wrong and supplied service reference has not been recognised :("
            }
        }
        return $CloudURI.ToLower()
    }
    catch {
        Invoke-Exception($_.Exception)
    }
}

function New-RandomComplexPassword ($length=12) {
    # Generate a complex password using characters from $chars

    $chars = [Char[]]"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"
    $password = ($chars | Get-Random -Count $length) -join ""
    return $password
}

function Invoke-Exception {
    write-host "`nCaught an exception: $($_.Exception.Message)" -ForegroundColor Red
    write-host "Exception Type: $($_.Exception.GetType().FullName) `n" -ForegroundColor Red
    break;
}

function Show-UntestedWarning {
    Write-Host "`nWarning: This cmdlet is untested - if you proceed and find stuff not working, please provide feedback to the developers`n" -ForegroundColor Yellow
    $okToContinue = Read-Host "Are you happy to continue? (type `"yes`" to continue)"
    if ($okToContinue -ne "yes")
    {
        Write-Host "`n --- You didn't enter yes - quitting`n`n"
        break;
    }
    else
    {
        Write-Host "`n --- Excellent, hang-on to your...`n"
    }
}

function Show-CloudAccounts {
    Import-Csv $Global:PoshNovaConfFile | ft -AutoSize

<#
 .SYNOPSIS
 Display all configured cloud accounts that are avaialble to use.

 .DESCRIPTION
 The Show-CloudAccounts cmdlet will simply display a list of all coud accounts, which have been configured in the $Global:PoshNovaConfFile.
 
 .EXAMPLE
 PS H:\> Show-CloudAccounts

 AccountName CloudUsername  CloudAPIKey                      CloudDDI Region
 ----------- -------------  -----------                      -------- ------
 prod        cloudProd      awefsrw2w34rf214aff46d3b9a73c6b0 11111111 LON   
 dev         cloudDev       9c2a200od18303ab763wt34gsd4bdb70 00000000 IAD 

#>
}
