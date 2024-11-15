#!/bin/bash
# The above line should be the shell you wish to execute this script.
#

# VERSION="2.0.1"
# MODIFIED="Nov 14, 2024"

# remote.it Example Script for setting Status A-E

# Status A = Free disk space, listed by partition
# Status B = Linux version info from uname -a
# Status C = System uptime since last boot
# Status D = List of all running processes
# Status E = Shell version
#
#
# These environment Variables are available to the script:
# JOB_DEVICE_ID - The job device ID of the device being managed
# GRAPHQL_API_PATH - The GraphQL API path to the remote.it api server

exec > ./external_script.log 2>&1
set -x  # Start logging all commands executed


# A Function to set a single status (statusA, statusB, statusC, etc.)
# Status columns can be displayed on the device list
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


# Clear Status
Status a ""
Status b ""
Status c ""
Status d ""
Status e ""

#-------------------------------------------------
# Update status column A in remote.it portal with free disk space
# retrieve the free disk space
diskfree="$(df)"
Log "Status a diskfree: $diskfree"
# send to status column a in remote.it portal
Status a "$diskfree"
#-------------------------------------------------

#-------------------------------------------------
# Update status column B in remote.it portal with kernel
# retrieve the Linux kernel version
fwversion="$(uname -a)"
Log "Status b fwversion: $fwversion"
# send to status column b in remote.it portal
Status b "$fwversion"
#-------------------------------------------------

#-------------------------------------------------
# Update status column C in remote.it portal with uptime
# retrieve the system uptime 
uptime="$(uptime)"
Log "Status c uptime: $uptime"
# send to status column c in remote.it portal
Status c "$uptime"
#-------------------------------------------------

#-------------------------------------------------
# Update status column D in remote.it portal with vmstat
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
Log "Status d vmstat: $vmstat_output"
# set attribute for vmstat
Status d "$vmstat_output"
#-------------------------------------------------

#-------------------------------------------------
# Update status column E in remote.it portal with OS
# retrieve the os ID as reported by the command “cat /etc/os-release”
os=$(cat /etc/os-release | grep -w ID | awk -F "=" '{print $2 }')
# send to status column e in remote.it portal
Status e "$os"
#-------------------------------------------------

#=======================================================================
# Lastly finalize job, no updates allowed after this
exit 0

# Use this line in case of error
# exit 1

