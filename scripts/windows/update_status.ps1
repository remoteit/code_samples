# This script is the PowerShell version for Windows

# Environment Variables Available
# $Env:JOB_DEVICE_ID - The job device ID of the device being managed
# $Env:GRAPHQL_API_PATH - The REST API path to the remote.it api server

Function Log {
    Param (
        [string]$Message
    )
    $Message | Out-File "$PSScriptRoot.log" -Append
}

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
