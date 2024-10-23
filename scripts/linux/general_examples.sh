#!/bin/bash
# The above line should be the shell you wish to execute this script.
#
# remote.it Example Script
# This has examples of the following (typically you will not being doing all of these at the same time):
# * graphQL mutations for Attributes (general attributes are displayed on the device detail page)
# * Setting Status columns with values that can be viewed in the portal and desktop applications
# * Has examples of usage of Environment variables
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
# The following defines arguments for selecting a file, entering a string or selecting from a list of strings:
# These arguments are optional and can be removed if not needed.
# Once defined their values can be accessed  via their name in the script (e.g., $textFile, $url, $name, $action)
# <arguments>, <type>, <name>, <prompt>, <option1>, <option2>, ... 
# r3_argument, FileSelect, textFile, Select File, .txt
# r3_argument, StringEntry, url, Enter Fully-Qualified URL
# r3_argument, StringEntry, name, Enter a Name
# r3_argument, StringSelect, action, Choose Action, ADD, REMOVE
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

# Clear all Attributes
Attribute diskfree ""
Attribute fwversion ""
Attribute uptime ""
Attribute vmstat ""
Attribute shell ""
Attribute textFile ""
Attribute url ""
Attribute name ""
Attribute action ""
Attribute fileContents ""

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
Log "textFile: $textFile"
Attribute textFile "$textFile"
Log "url: $url"
Attribute url "$url"
Log "name: $name"
Attribute name "$name"
Log "action: $action"
Attribute action "$action"

# Log contents of the file named in fileName
Log "textFile File Contents: $(cat $textFile)"
Attribute fileContents "$(cat $textFile)"

#=======================================================================
# Lastly finalize job, no updates allowed after this
exit 0

# Use this line in case of error
# exit 1

