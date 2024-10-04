#!/bin/bash

# Function to set an attribute on the device
set_attribute() {
    local name="$1"
    local value="$2"

    # Send the data to the API, including jobDeviceId and attributeName in the URL
    curl -X POST "https://${GRAPHQL_API_PATH}/job/attribute/${JOB_DEVICE_ID}/${name}" \
         -H "Content-Type: text/plain" \
         --data "${value}"
}

# Create and set a hostname attribute
set_attribute "hostname" "$(hostname)"
