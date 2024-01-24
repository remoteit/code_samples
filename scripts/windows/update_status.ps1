# This script is the PowerShell version for Windows
# This example script first clears all the status columns (Status A-E) for the device
# Next this script gets the following system values and sets Status values 
#
# Status A = Free disk space. listed by partition
# Status B = Windows Version
# Status C = System uptime since last boot
# Status D = list of all running processes
# Status E = Powershell version


# Environment Variables Available
# $Env:JOB_DEVICE_ID - The job device ID of the device being managed
# $Env:REST_API_PATH - The REST API path to the remote.it api server

# Functions
Function Set-Status {
    Param (
        [string]$StatusKey,
        [string]$StatusValue
    )
    $jobDeviceId = $Env:JOB_DEVICE_ID
    $attributes = @{
        $StatusKey = $StatusValue
    }
    $body = @{
        jobDeviceId = $jobDeviceId
        attributes = @{
            '$remoteit' = $attributes
        }
    } | ConvertTo-Json

    $uri = "$Env:REST_API_PATH/job/attributes"
    Invoke-RestMethod -Method Post -Uri $uri -ContentType "application/json" -Body $body
}

Function Log {
    Param (
        [string]$Message
    )
    $Message | Out-File "$PSScriptRoot.log" -Append
}

# Clear all status columns A-E in remote.it portal
1..5 | ForEach-Object { Set-Status (Get-Variable -Name "a$_").Value "" }

# Update status column A (StatusA) - Free disk space
$diskFree = Get-PSDrive | Where-Object { $_.Provider -like "Microsoft.PowerShell.Core\FileSystem" }
Log "diskFree: $diskFree"
Set-Status "a" $diskFree

# Update status column B (StatusB) - Windows version info
$fwVersion = (Get-WmiObject Win32_OperatingSystem).Caption
Log "fwVersion: $fwVersion"
Set-Status "b" $fwVersion

# Update status column C (StatusC) - System uptime
$uptime = (Get-Uptime).ToString()
Log "uptime: $uptime"
Set-Status "c" $uptime

# Update status column D (StatusD) - List of running processes
$vmStat = Get-Process | Out-String
Log "vmStat: $vmStat"
Set-Status "d" $vmStat

# Update status column E (StatusE) - PowerShell version
$shellVersion = $PSVersionTable.PSVersion.ToString()
Log "shell: $shellVersion"
Set-Status "e" $shellVersion

# Echo all inputs to the log file
Log "JOB_DEVICE_ID: $Env:JOB_DEVICE_ID"
Log "REST_API_PATH: $Env:REST_API_PATH"

Log "fileName: $Env:fileName"
Log "url: $Env:url"
Log "bookmarkName: $Env:bookmarkName"
Log "action: $Env:action"

# Log contents of the file named in fileName
$fileNameContent = Get-Content $Env:fileName -Raw
Log "fileName File Contents: $fileNameContent"

#=======================================================================
# Lastly finalize job, no updates allowed after this, this indicates that the job is done for this device with success.
exit 0

# Use this line in case of error, this will indicate that the job is done with error for this device.
# e