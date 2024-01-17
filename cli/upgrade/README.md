# Upgrade script for Remote.It CLI <!-- omit in toc --> 

This is a script to upgrade the legacy version of the Remote.It CLI.

For Windows: upgrade_cli.bat  
For Linux: upgrade_cli.sh  

## Supported versions

Legacy versions of Remote.It CLI supported by this script are:

v1.4.x, v1.5.x, v1.6.x, v1.7.x, v1.8.x, v2.0.x, v3.0.x

The target of updated version is defined by the variable "VERSION".  
The currently tested and supported upgrade target version is v3.0.38.

## Supported OS (especialy Windows)

The following operating systems have been verified this script works.

Windows 10 / 11

It may not work well on Windows 7. In that case, please update the Remote.It CLI manually without this script. If you do not know the procedure, please contact our support.

support@remote.it

## Caution

- This script does not work well in environments where the Remote.It Desktop application is installed. It must be run in an environment where only the Remote.It CLI is installed.
- When this script is running, the target device will be temporarily offline and the initiator connection will be disconnected. They should automatically recover once the update is successfully completed.

## How to use

[Local Update]
1. Copy the upgrade script to a directory of your choice and grant execution permission.
2. Then execute this script with administrator or root privileges.

[Remote Upadate]
1. Connect remotely to the device where the old CLI is installed using the remote.it connection.
   Windows:RDP, Linux:SSH
2. Copy the upgrade script to a directory of your choice on the device which has installed old CLI and grant execution permission.
3. Then execute this script with administrator or root privileges.
   Note: for Linux, run the following special command.
         $ nohup sudo ./upgrade_cli.sh -f &
   
   The device will go offline and remote.it connection is disconnected, but then come back online automatically.
