#!/bin/bash
# The above line should be the shell you wish to execute this script.
#
# remote.it Example Script
#
# This script first clears all the attributes for the device (diskfree, fwversion, uptime, vmstat, shell).
# Next, it collects specific system values from a device and sets them as attributes.
#
# Attribute diskfree = Free disk space, listed by partition
# Attribute fwversion = Linux version info from uname -a
# Attribute uptime = System uptime since last boot
# Attribute vmstat = List of all running processes
# Attribute shell = Shell version
#
# Finally, it sets the statusA field to complete with the current date and time. (e.g., "Complete: 2021-01-01 12:00:00")
#
# These enivronment Variables are available to the script:
# JOB_DEVICE_ID - The job device ID of the device being managed
# GRAPHQL_API_PATH - The GraphQL API path to the remote.it api server

exec > ./external_script.log 2>&1
set -x  # Start logging all commands executed

# A Function to set a single attribute
# These attribute values are displayed in the remote.it portal under the device's attributes
# $1 = attribute name (e.g., 'customAttribute')
# $2 = attribute value (e.g., 'some value')
Attribute() {
    ATTRIBUTE_NAME="$1"
    ATTRIBUTE_VALUE="$2"

    # Send the data to the API, including jobDeviceId and attributeName in the URL
    curl -X POST "https://${GRAPHQL_API_PATH}/job/attribute/$JOB_DEVICE_ID/$ATTRIBUTE_NAME" \
         -H "Content-Type: text/plain" \
         --data "$ATTRIBUTE_VALUE"
}

# A Function to set a single status (statusA, statusB, statusC, etc.)
# $1 = status letter (e.g., 'a')
# $2 = status value (e.g., 'some value')
Status()
{
    SHORTHAND=$(echo "$1" | tr '[:lower:]' '[:upper:]')
    ATTRIBUTE_NAME="\$remoteit.status${SHORTHAND}"
    ATTRIBUTE_VALUE="$2"

   # Send the data to the API, including jobDeviceId and attributeName in the URL
    curl -X POST "https://${GRAPHQL_API_PATH}/job/attribute/$JOB_DEVICE_ID/$ATTRIBUTE_NAME" \
         -H "Content-Type: text/plain" \
         --data "$ATTRIBUTE_VALUE"
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

# Clear Status
Status a ""

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
# set attribute for shell
Attribute shell "$SHELL"
#-------------------------------------------------

#-------------------------------------------------
# Set status A to "complete: date and time"
Status a "Complete: $(date)"

# Echo all inputs to the log file
Log "JOB_DEVICE_ID: $JOB_DEVICE_ID"
Log "GRAPHQL_API_PATH: $GRAPHQL_API_PATH"

#=======================================================================
# Lastly finalize job, no updates allowed after this
exit 0

# Use this line in case of error
# exit 1

