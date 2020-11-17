<#

Title: Deploy FSRM Killswitch
Description: Quickly create a functional killswitch using FSRM (File Server Resource Manager) including all pre-requisite items
Author: Nathan Magyar <nathanlmagyar@gmail.com>
Version: V1.0.0
Date Created: 30/10/2020

#>

# Define error action preference
$errorActionPreference = SilentlyContinue

# Create ACL Object
$NewAcl = Get-Acl -Path "C:\"
$identity = "Everyone"
$fileSystemRights = "FullControl"
$type = "Allow"
$fileSystemAccessRuleArgumentList = $identity, $fileSystemRights, $type
$fileSystemAccessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $fileSystemAccessRuleArgumentList
$NewAcl.SetAccessRule($fileSystemAccessRule)

# Get Paths
$paths = (Get-SMBShare | Select Path).Path

# Setup directories, in Alphabetical and Reverse-Alphabetical order
$directories = "_killswitch","ZZZZKillswitch"

#Assign Extensions, this can be modified to include/exclude whatever you please
$extensions = "avi","bmp","mdb","doc","jpg","exe","docx","png","gif","msi","xls","xlsx","csv","txt","sln","mp4","mov","jpeg"

# Create Directories
foreach ($path in $paths) {
    foreach ($directory in $directories) {
    New-Item -Path $path -Name $directory -ItemType "Directory"
    }
}

# Create list of SubPaths
$subPaths = foreach ($path in $paths) {
    (Get-ChildItem $path | Where-Object {$_.Name -match "_Killswitch" -or $_.Name -match "ZZZZKillswitch"} | Select Name).Name
}

# Set Killswitch Directory permissions
Get-SMBShare | forEach ($_.Path ) {
    $items = (Get-ChildItem -Path $_.Path | Where-Object {$_.Name -like "*kill*"} | select Name).Name
    forEach ($item in $items) {
        $fullPath = $_.Path + "\" + $item
        Write-Host "Assigning permissions to $fullPath"
        Set-Acl -Path $fullPath -AclObject $NewAcl
    }
}

# Logic, used to ensure that files aren't created anywhere other than where they are supposed to be created
foreach ($extension in $extensions) {
    foreach ($subpath in $subpaths) {
        foreach ($path in $paths) {
            foreach ($directory in $directories) {
                if ("$path\$subpath" -ne $path -and $null -ne $subpath) {
                New-Item -Path "$path\$subpath" -Name "$directory.$extension" -ItemType "File"
                }
            }
        }
    }
}

# Define FSRM Variables
$notificationLimit = 1
$fileGroup = "All File Types - Killswitch"
$fileScreenTemplate = "Killswitch"

# Set notification limits to 1 per minute
Set-FsrmSetting -CommandNotificationLimit $notificationLimit -EventNotificationLimit $notificationLimit 

# Create FSRM File Group
New-FsrmFileGroup -Name $fileGroup -IncludePattern @("*.*")

# Create FSRM Action Objects 
$commandAction = New-FsrmAction -Type Command -Command "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -CommandParameters "-Command & {C:\Script\block-smbshareaccess.ps1 -username ‘[Source Io Owner]’}"
$eventLogAction = New-FsrmAction -Type Event -EventType Warning -Body "WARNING! User [Source Io Owner] attempted to save [Source File Path] to [File Screen Path] on the [Server] server. This file is in the [Violated File Group] file group, which is not permitted on the server."

# Create FSRM File Screen Template
New-FsrmFileScreenTemplate -Name $fileScreenTemplate -IncludeGroup $fileGroup -Notification $commandAction,$eventLogAction

# Create FSRM File Screens from aforementioned File Screen Template
forEach ($path in $paths) {
    $path = $path + "\ZZZZkillswitch"
    New-FsrmFileScreen -Path $path -Template $fileScreenTemplate
}
forEach ($path in $paths) {
    $path = $path + "\_killswitch"
    New-FsrmFileScreen -Path $path -Template $fileScreenTemplate
}
