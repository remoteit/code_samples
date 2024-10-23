#!/bin/bash
# The above line should be the shell you wish to execute this script
# and will only work on devices which can run bash scripts

# Function to set an attribute on the device
set_attribute() {
    local name="$1"
    local value="$2"
    curl -X POST "https://${GRAPHQL_API_PATH}/job/attribute/${JOB_DEVICE_ID}/${name}" \
         -H "Content-Type: text/plain" \
         --data "${value}"
}

# Get the hostname and set it as a device attribute
set_attribute "hostname" "$(hostname)"
