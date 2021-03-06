<############################################################################################

                           ___          _         __                
                          / _ \___  ___| |__   /\ \ \_____   ____ _ 
                         / /_)/ _ \/ __| '_ \ /  \/ / _ \ \ / / _` |
                        / ___/ (_) \__ \ | | / /\  / (_) \ V / (_| |
                        \/    \___/|___/_| |_\_\ \/ \___/ \_/ \__,_|
                                                     Module Manifest 
                                                         Version 0.1

Authors
-----------
    Nielsen Pierce (nielsen.pierce@rackspace.co.uk)
    Alexei Andreyev (alexei.andreyev@rackspace.co.uk)
    
Description
-----------
PowerShell v3 module for interaction with Rackspace Cloud API (PoshNova) 

Module manifest for module 'PoshNova'

############################################################################################>

@{

# Script module or binary module file associated with this manifest.
RootModule = 'PoshNova.psm1'

# Version number of this module.
ModuleVersion = '0.1'

# ID used to uniquely identify this module
GUID = 'baa1e88f-ba18-44d3-81e9-c23d531e15e1'

# Author of this module
Author = 'nielsen.pierce'

# Company or vendor of this module
CompanyName = ''

# Copyright statement for this module
Copyright = ''

# Description of the functionality provided by this module
Description = "Powershell client for Rackspace Cloud API's"

# Minimum version of the Windows PowerShell engine required by this module
 PowerShellVersion = '3.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
 PowerShellHostVersion = '3.0'

# Minimum version of the .NET Framework required by this module
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = ""

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
 ScriptsToProcess = @(
# "PoshNova-AutoScale.ps1", Future development
"PoshNova-CloudMonitoring.ps1",
"PoshNova-CloudFiles.ps1",
"PoshNova-CloudLoadBalancers.ps1",
"PoshNova-Identity.ps1",
"PoshNova-CloudBlockStorage.ps1",
"PoshNova-CloudNetworks.ps1",
"PoshNova-CloudServers.ps1"
)

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = 

# Functions to export from this module
FunctionsToExport = '*'

# Cmdlets to export from this module
CmdletsToExport = '*'

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module
AliasesToExport = '*'

# List of all modules packaged with this module.
# ModuleList = @()

# List of all files packaged with this module
#FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess
# PrivateData = ''

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

