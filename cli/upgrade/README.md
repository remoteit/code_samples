# Upgrade script for Remote.It CLI <!-- omit in toc --> 

This is a script to upgrade the legacy version of the Remote.It CLI.

For Windows: upgrade_cli.bat  
For Linux: N/A (prepared in the near future)

## Supported versions

Legacy versions of Remote.It CLI supported by this script are:

v1.4.x, v1.5.x, v1.6.x, v1.7.x, v1.8.x, v2.0.x

The target of updated version is defined by the variable "VERSION".  
The currently tested and supported version is v3.0.33.

## Supported OS

The following operating systems have been verified this script works.

Windows 10 / 11

It may not work well on Windows 7. In that case, please update the Remote.It CLI manually without this script. If you do not know the procedure, please contact our support.

support@remote.it

## Caution

- This script does not work well in environments where the Remote.It Desktop application is installed. It must be run in an environment where only the Remote.It CLI is installed.
- When this script is running, the target device will be temporarily offline and the initiator connection will be disconnected. They should automatically recover once the update is successfully completed.

## How to use

1. Copy the upgrade script to a directory of your choice.
2. Then execute this script with administrator privileges.
