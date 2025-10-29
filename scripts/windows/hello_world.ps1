function Set-Attribute {
    param (
        [string]$attributeName,
        [string]$attributeValue
    )

    Invoke-RestMethod -Uri "https://$env:GRAPHQL_API_PATH/job/attribute/$env:JOB_DEVICE_ID/$attributeName" `
        -Method Post -ContentType "text/plain" -Body $attributeValue
}

$hostname = [System.Environment]::MachineName
Set-Attribute -attributeName "hostname" -attributeValue $hostname

exit 0
