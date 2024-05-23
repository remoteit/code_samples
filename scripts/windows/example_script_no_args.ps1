# This script first clears all the attributes for the device (diskfree, fwversion, uptime, vmstat, shell).
# Next, it collects specific system values from a device and sets them as attributes.
#
# Attribute diskfree = Free disk space, listed by partition
# Attribute fwversion = Windows version info
# Attribute uptime = System uptime since last boot
# Attribute vmstat = List of all running processes
# Attribute shell = PowerShell version
#
# Finally, it sets the statusA field to complete with the current date and time. (e.g., "Complete: 2021-01-01 12:00:00")
#
# These environment Variables are available to the script:
# JOB_DEVICE_ID - The job device ID of the device being managed
# GRAPHQL_API_PATH - The GraphQL API path to the remote.it api server

# Start logging all commands executed
Start-Transcript -Path ./external_script.log -Append

# A Function to set a single attribute
# These attribute values are displayed in the remote.it portal under the device's attributes
# $attributeName = attribute name (e.g., 'customAttribute')
# $attributeValue = attribute value (e.g., 'some value')
function Set-Attribute {
    param (
        [string]$attributeName,
        [string]$attributeValue
    )
    # Send the data to the API, including jobDeviceId and attributeName in the URL
    Invoke-RestMethod -Uri "https://$env:GRAPHQL_API_PATH/job/attribute/$env:JOB_DEVICE_ID/$attributeName" -Method Post -ContentType "text/plain" -Body $attributeValue
}

# A Function to set a single status (statusA, statusB, statusC, etc.)
# $statusLetter = status letter (e.g., 'a')
# $statusValue = status value (e.g., 'some value')
function Set-Status {
    param (
        [string]$statusLetter,
        [string]$statusValue
    )
    $shorthand = $statusLetter.ToUpper()
    $attributeName = "\$remoteit.status$shorthand"
    # Send the data to the API, including jobDeviceId and attributeName in the URL
    Invoke-RestMethod -Uri "https://$env:GRAPHQL_API_PATH/job/attribute/$env:JOB_DEVICE_ID/$attributeName" -Method Post -ContentType "text/plain" -Body $statusValue
}

# Function to Log data to a file
function Log {
    param (
        [string]$message
    )
    Add-Content -Path "./external_script.log" -Value $message
}

# Clear all Attributes
Set-Attribute -attributeName "diskfree" -attributeValue ""
Set-Attribute -attributeName "fwversion" -attributeValue ""
Set-Attribute -attributeName "uptime" -attributeValue ""
Set-Attribute -attributeName "vmstat" -attributeValue ""
Set-Attribute -attributeName "shell" -attributeValue ""
Set-Attribute -attributeName "textFile" -attributeValue ""
Set-Attribute -attributeName "url" -attributeValue ""
Set-Attribute -attributeName "name" -attributeValue ""
Set-Attribute -attributeName "action" -attributeValue ""
Set-Attribute -attributeName "fileContents" -attributeValue ""

# Clear Status
Set-Status -statusLetter "a" -statusValue ""

#-------------------------------------------------
# retrieve the freed disk space
$diskfree = Get-PSDrive -PSProvider FileSystem | Select-Object Name, @{Name="Free(GB)";Expression={[math]::round($_.Free/1GB,2)}}
Log "diskfree: $($diskfree | Out-String)"
# send to status column a in remote.it portal
Set-Attribute -attributeName "diskfree" -attributeValue ($diskfree | Out-String)
#-------------------------------------------------

#-------------------------------------------------
# retrieve the Windows version info
$fwversion = Get-WmiObject -Class Win32_OperatingSystem | Select-Object Caption, Version
Log "fwversion: $($fwversion | Out-String)"
# send to status column b in remote.it portal
Set-Attribute -attributeName "fwversion" -attributeValue ($fwversion | Out-String)
#-------------------------------------------------

#-------------------------------------------------
# retrieve the system uptime 
$uptime = (Get-WmiObject -Class Win32_OperatingSystem).ConvertToDateTime((Get-WmiObject -Class Win32_OperatingSystem).LastBootUpTime)
Log "uptime: $uptime"
# send to status column c in remote.it portal
Set-Attribute -attributeName "uptime" -attributeValue $uptime
#-------------------------------------------------

#-------------------------------------------------
# get the list of running processes
$vmstat_output = Get-Process | Select-Object Id, ProcessName
Log "vmstat: $($vmstat_output | Out-String)"
# set attribute for vmstat
Set-Attribute -attributeName "vmstat" -attributeValue ($vmstat_output | Out-String)
#-------------------------------------------------

#-------------------------------------------------
# use the PowerShell variable $PSVersionTable.PSVersion to get the PowerShell version
$shell = $PSVersionTable.PSVersion.ToString()
Log "shell: $shell"
# set attribute for shell
Set-Attribute -attributeName "shell" -attributeValue $shell
#-------------------------------------------------

#-------------------------------------------------
# Set status A to "complete: date and time"
Set-Status -statusLetter "a" -statusValue ("Complete: " + (Get-Date))

# Stop logging
Stop-Transcript

# Lastly finalize job, no updates allowed after this
exit 0

# Use this line in case of error
# exit 1
