#!/bin/bash

Attribute() {
    ATTRIBUTE_NAME="$1"
    ATTRIBUTE_VALUE="$2"

    # Send the data to the API, including jobDeviceId and attributeName in the URL
    curl -X POST "https://${GRAPHQL_API_PATH}/job/attribute/$JOB_DEVICE_ID/$ATTRIBUTE_NAME" \
         -H "Content-Type: text/plain" \
         --data "$ATTRIBUTE_VALUE"
}

Attribute hello "world"
Attribute hostname "$(hostname)"
