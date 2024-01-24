#!/bin/bash

# This example script first clears all the status columns (Status A-E) for the device
# Next this script gets the following system values and sets Status values 
#
# Status A = Free disk space. listed by partition
# Status B = Linux version info per uname -a
# Status C = System uptime since last boot
# Status D = list of all running processes
# Status E = Shell version

# Function to set a single status attribute
# $1 = attribute name (e.g., 'customAttribute')
# $2 = attribute value (e.g., 'some value')
Attribute()
{
    ATTRIBUTE_NAME=$1
    ATTRIBUTE_VALUE=$2

    # Construct JSON data
    JSON_DATA="{ \"jobDeviceId\": \"$JOB_DEVICE_ID\", \"attributes\": { \"$ATTRIBUTE_NAME\": \"$ATTRIBUTE_VALUE\" } }"

    # Send the data to the API
    curl -X POST "https://${GRAPHQL_API_PATH}/job/attributes" \
         -H "Content-Type: application/json" \
         --data "$JSON_DATA"
}

# Function to Log data to a file
Log()
{
	echo "$1" >> $0.log
}

# Clear all Attributes
Attribute diskfree ""
Attribute fwversion ""
Attribute uptime ""
Attribute vmstat ""
Attribute shell ""

#-------------------------------------------------
# retrieve the freed disk space
diskfree="$(df)"
Log "diskfree: $diskfree"
# send to status column a in remote.it portal
Attribute diskfree "$diskfree"
#-------------------------------------------------

#-------------------------------------------------
# retrieve the Linux kernel version
fwversion="$(uname -a)"
Log "fwversion: $fwversion"
# send to status column b in remote.it portal
Attribute fwversion "$fwversion"
#-------------------------------------------------

#-------------------------------------------------
# retrieve the system uptime 
uptime="$(uptime)"
Log "uptime: $uptime"
# send to status column c in remote.it portal
Attribute uptime "$uptime"
#-------------------------------------------------

#-------------------------------------------------
# get the list of running processes
# Check if vm_stat is available (common on macOS)
if command -v vm_stat &> /dev/null; then
    vmstat_output="$(vm_stat)"
# Otherwise, check if vmstat is available (common on Linux)
elif command -v vmstat &> /dev/null; then
    vmstat_output="$(vmstat)"
else
    # If neither command is available, set vmstat_output to an error message
    vmstat_output="Neither vm_stat nor vmstat is available on this system."
fi
Log "vmstat: $vmstat_output"
# set attribute for vmstat
Attribute vmstat "$vmstat_output"
#-------------------------------------------------

#-------------------------------------------------
# use the shell variable $SHELL to get the shell version
Log "shell: $SHELL"
# send to status e
Attribute shell "$SHELL"
#-------------------------------------------------

# Echo all inputs to the log file
Log "JOB_DEVICE_ID: $JOB_DEVICE_ID"
Log "GRAPHQL_API_PATH: $GRAPHQL_API_PATH"
Log "fileName: $fileName"
Log "url: $url"
Log "bookmarkName: $bookmarkName"
Log "action: $action"

# Log contents of the file named in fileName
Log "fileName File Contents: $(cat $fileName)"

#=======================================================================
# Lastly finalize job, no updates allowed after this, this indicates that the job is done for this device with success.
exit 0

# Use this line in case of error, this will indicate that the job is done with error for this device.
# e