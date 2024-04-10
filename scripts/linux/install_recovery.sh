#!/bin/sh
# The above line should be the shell you wish to execute this sccript with.
# Raspberry Pi supports bash shell and sh
#
# remote.it Bulk Management Status Script
#
# $1 parameter is the jobID used for completion status
# $2 is API server
# $3 is the bulk identification code for the recovery device.
#
# This example script does the following:

# 1. Sets CLI version as Status A value 
# 2. Sets remoteit/connectd package version as Status B
# 3. Installs the recovery daemon to register as temporary access
# 4. Sets Device ID of recovery device as Status C
# 5. Sets tag of new device to "upgrade_ready"
#


ret=$(/usr/bin/connectd_task_notify 0 $1 $2 "Job started")
echo "Return value: \"${ret}\"" > /tmp/remoteit-script-cmds.txt

VERSION="1.1.0"
MODIFIED="April 9, 2023"
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin

# this will display debug output on the console when the script is run.
set -x

echo "$1\n$2\n$3" > /tmp/remoteit-script-params.txt

# look for OpenWrt, ps provided through BusyBox, different options
# than full Linux
if [ $(grep -i openwrt /etc/os-release | wc -l) -gt 0 ]; then
  PSFLAGS=w
else
  PSFLAGS=ax
fi

# look for remoteit 4.x
if [ -e /usr/share/remoteit/task_notify.sh ]; then
  TOOL_DIR="/usr/share/remoteit"
  NOTIFIER=task_notify.sh
  package=remoteit
  logger "remoteit package found."
  cversion=$(cat ${TOOL_DIR}/version.txt)
# look for weavedconnectd package notifier
elif [ -e /usr/bin/task_notify.sh ]; then
  NOTIFIER=task_notify.sh
  TOOL_DIR="/usr/bin"
  package=weavedconnectd
  # get the package version of whichever package is installed
  cversion=$(dpkg -s $package | grep Version)
  logger "Weaved package found."
# need to account for possibly remoteit installed over connectd
# so check for remoteit first.
elif [ -f /usr/bin/connectd_task_notify ]; then
  TOOL_DIR="/usr/bin"
  NOTIFIER=connectd_task_notify

  dpkg -s remoteit
  if [ $? -eq 0 ]; then
  package=remoteit
  # get the package version of whichever package is installed
  cversion=$(dpkg -s $package | grep Version)
  logger "remoteit status script"
  else
  dpkg -s remoteit-desktop
  if [ $? -eq 0 ]; then
  NOTIFIER=connectd_task_notify
  package=remoteit-desktop
  # get the package version of whichever package is installed
  cversion=$(dpkg -s $package | grep Version)
  logger "remoteit-desktop status script"
  else
  dpkg -s connectd
  if [ $? -eq 0 ]; then
  package=connectd
  # get the package version of whichever package is installed
  cversion=$(dpkg -s $package | grep Version)
  logger "connectd status script"
  else
  if [ -f "${TOOL_DIR}/remoteit" ]; then
          package=cli
          # get the remoteit cli version
  cversion=$(${TOOL_DIR}/remoteit version)
  logger "remoteit cli status script"
        elif [ -f "${TOOL_DIR}/connectd" ]; then
          package=connectd
          # get the connectd version
          cversion="connectd ${TOOL_DIR}/connectd -v"
  else
  logger "remoteit $0 error - couldn't identify package"
  # There is no point in calling the NOTIFIER, since we couldn't find it.
  # ret=$(${TOOL_DIR}/${NOTIFIER} 2 $1 $2 "Couldn't identify package")
  exit 1
  fi
  fi
  fi
  fi
## Check if running on macos
elif [ -f /usr/local/bin/connectd_task_notify ]; then
  TOOL_DIR="/usr/local/bin"
  NOTIFIER=connectd_task_notify

  is_darwin=$(uname -s | grep -i 'darwin')
  if [ $? -eq 0 ]; then
  package="desktop"
    connectd_sympath=$(which connectd)
    connectd_realpath=$(readlink ${connectd_sympath})
    connectd_dir=$(dirname ${connectd_realpath})
    app_dir=$(builtin cd $connectd_dir/../..; pwd)
    plist_file="${app_dir}/Contents/Info.plist"
    plist_version_string=$(plutil -p ${plist_file} | grep "CFBundleShortVersionString.*$ApplicationVersionNumber")
    plist_version=$(echo ${plist_version_string} | cut -w -f3 | xargs)
    cversion=${plist_version}
    logger "remoteit cversion - ${cversion}"
  fi
fi

# Mark the job as started
##ret=$(${TOOL_DIR}/${NOTIFIER} 0 $1 $2 "Job started")

# Clear all status columns A-E in remote.it portal

ret=$(${TOOL_DIR}/${NOTIFIER} a $1 $2 "")
ret=$(${TOOL_DIR}/${NOTIFIER} b $1 $2 "")
ret=$(${TOOL_DIR}/${NOTIFIER} c $1 $2 "")
ret=$(${TOOL_DIR}/${NOTIFIER} d $1 $2 "")
ret=$(${TOOL_DIR}/${NOTIFIER} e $1 $2 "")

# Update status column A (StatusA) in remote.it portal for CLI version
#-------------------------------------------------
cli_version = "unknown"
cli_version = "$(remoteit version)"
# send to status column a in remote.it portal
echo "${TOOL_DIR}/${NOTIFIER} a $1 $2 $cli_version" > /tmp/remoteit-script-cmds.txt
ret=$(${TOOL_DIR}/${NOTIFIER} a $1 $2 $cli_version)
echo "Return value: \"${ret}\"" >> /tmp/remoteit-script-cmds.txt
#-------------------------------------------------

# Update status column B (StatusB) in remote.it portal
#-------------------------------------------------
# send cversion to status b
echo "${TOOL_DIR}/${NOTIFIER} b $1 $2 \"${package} ${cversion}\"" >> /tmp/remoteit-script-cmds.txt
ret=$(${TOOL_DIR}/${NOTIFIER} b $1 $2 "${package} ${cversion}")
echo "Return value: \"${ret}\"" >> /tmp/remoteit-script-cmds.txt
#-------------------------------------------------

#Install the recovery package
#-------------------------------------------------
# the package will set the device name as the Device ID from the original /etc/remoteit/config.json (inside the package) otherwise it will just be the host name
# download the package:

wget https://s3.us-west-2.amazonaws.com/downloads.remote.it/remoteit/v5.1.4/Ackcio/remoteitrecovery-5.1.4b.armhf.rpi.deb

sudo mkdir -p /etc/remoteitrecovery
sudo touch /etc/remoteitrecovery/registration
echo $3 | sudo tee /etc/remoteitrecovery/registration
sudo apt install ./remoteitrecovery-5.1.4b.armhf.rpi.deb
#=======================================================================

# Check the exit status of the previous commands
if [ $? -eq 0 ]; then
    echo "Install happened successfully"
    #set the tag on the original device to "upgrade_ready"

    # Lastly finalize job, no updates allowed after this
    ret=$(${TOOL_DIR}/${NOTIFIER} 1 $1 $2 "Job complete")
else
    echo "Update failed."
    ret=$(${TOOL_DIR}/${NOTIFIER} 1 $1 $2 "Job Failed")
fi

