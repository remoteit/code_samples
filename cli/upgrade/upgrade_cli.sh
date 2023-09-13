#!/bin/sh

# Set the variable.
CLI="/usr/bin/remoteit"
BIN_DIR="/usr/bin"
CONNECTD="/usr/bin/connectd"
MUXER="/usr/bin/muxer"
DEMUXER="/usr/bin/demuxer"
CONFIG="/etc/remoteit/config.json"
LOG_DIR="/var/log/remoteit"
SCRIPT_DIR="$(cd $(dirname $0); pwd)"

# Upgrade to
VERSION="latest"

# Below is the rollback process in case the latest CLI did not start. Restore from a backed up file.
rollback() {
    echo 
    echo "Rollbacking....."
    $SUDO remoteit agent stop
    $SUDO remoteit agent uninstall
    $SUDO remoteit tools uninstall
    $SUDO rm $CONFIG
    $SUDO cp -f "$SCRIPT_DIR/r3_cli_upgrade/backup/bin/remoteit" $BIN_DIR
    $SUDO remoteit tools install
    $SUDO cp -f "$SCRIPT_DIR/r3_cli_upgrade/backup/bin/connectd" $BIN_DIR
    $SUDO cp -f "$SCRIPT_DIR/r3_cli_upgrade/backup/bin/muxer" $BIN_DIR
    $SUDO cp -f "$SCRIPT_DIR/r3_cli_upgrade/backup/bin/demuxer" $BIN_DIR
    $SUDO cp -f "$SCRIPT_DIR/r3_cli_upgrade/backup/config/config.json" $CONFIG
    $SUDO remoteit agent install 
}

echo "----------------------------------------------"
echo "Upgrade Remote.It CLI."
echo "Older versions to be upgraded include:"
echo "v1.4.x, v1.5.x, v1.6.x, v1.7.x, v1.8.x, v2.0.x"
echo "----------------------------------------------"

# Detection of whether the user executing the shell is root.
SUDO=
if [ $(id -u) -ne 0 ]; then
  SUDO=sudo
fi

# Check for the existence of each file and directory.
echo
echo "Checking if the binary file and log directory exists in the proper location....."
i=
for i in $CLI $BIN_DIR $CONNECTD $MUXER $DEMUXER $CONFIG $LOG_DIR
do
  if [ ! -e $i ]; then
    echo "$i is not exist."
    echo "Terminates processing of upgraging."
    echo "Please contact support."
    echo "support@remote.it"
    exit 1
  fi
done
sleep 3
echo "Done."

# Check if the installed version is supported with this script.
echo
echo "Checking if the installed version is supported with this script....."
sleep 3
INSTALLED_VERSION=$($SUDO remoteit version)
echo "Current installed version is Remote.It CLI v$INSTALLED_VERSION"
i=
for i in v1.4 v1.5 v1.6 v1.7 v1.8 v2.0
do
  echo v$INSTALLED_VERSION | grep $i >/dev/null
  if [ $? -eq 0 ]; then
    echo "This is the version to be upgraded."
    break
  else
    if [ $i = v2.0 ]; then
      echo "This is not the version to be upgraded."
      echo "Please contact support."
      echo "support@remote.it"
      exit 1
    fi
  fi
done

# Create the working folder for upgrading process.
mkdir -p "$SCRIPT_DIR/r3_cli_upgrade/backup/bin"
mkdir -p "$SCRIPT_DIR/r3_cli_upgrade/backup/config"
mkdir -p "$SCRIPT_DIR/r3_cli_upgrade/backup/log"
mkdir -p "$SCRIPT_DIR/r3_cli_upgrade/tmp"

# Backup files.
echo
echo "Backup the current files to r3_cli_upgrade dir....."
cp -f $CLI "$SCRIPT_DIR/r3_cli_upgrade/backup/bin"
cp -f $CONNECTD "$SCRIPT_DIR/r3_cli_upgrade/backup/bin"
cp -f $MUXER "$SCRIPT_DIR/r3_cli_upgrade/backup/bin"
cp -f $DEMUXER "$SCRIPT_DIR/r3_cli_upgrade/backup/bin"
cp -f $CONFIG "$SCRIPT_DIR/r3_cli_upgrade/backup/config"
cp -f $LOG_DIR/* "$SCRIPT_DIR/r3_cli_upgrade/backup/log"
sleep 3
echo "Done."

# Detect the cpu architecture for this device. (AMD64/IA64/ARM64/x86).
ARCH=$(uname -m)
echo
echo Arch is "$ARCH".
if [ "$ARCH" = "armv5l" ]; then
  SUFFIX="arm-v5"
elif [ "$ARCH" = "armhf" ] || [ "$ARCH" = "armv6l" ]; then
  SUFFIX="arm-v6"
elif [ "$ARCH" = "armv7l" ]; then
  SUFFIX="arm-v7"
elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
  SUFFIX="aarch64"
elif [ "$ARCH" = "x86_64" ] || [ "$ARCH" = "amd64" ]; then
  SUFFIX="x86_64"
else
  echo
  echo "This CPU architecture is not supported."
  echo "Please contact support."
  echo "support@remote.it"
  exit 1
fi

# Download the latest CLI.
echo
echo Downloading remoteit CLI $VERSION.....
curl -Lo "$SCRIPT_DIR/r3_cli_upgrade/tmp/remoteit" "https://downloads.remote.it/cli/$VERSION/remoteit.$SUFFIX-linux"
if [ $? -ne 0 ]; then
  echo
  echo "Download of the latest Remote.It CLI failed due to some problem."
  echo "Please contact support."
  echo "support@remote.it"
  exit 1
fi
chmod +x "$SCRIPT_DIR/r3_cli_upgrade/tmp/remoteit"
echo "Download complete."

# Alerts you whether or not to proceed with this upgrade process.
echo
echo "---------------------------------------------------------"
echo "It will stop the service of the old Remote.It CLI."
echo "This takes the target device offline and also disconnects"
echo "the initiator connection if it has one."
echo "---------------------------------------------------------"

# Check if you want to continue the process, if Yes, continue processing.
while true
do
  echo
  echo "Continue? [Y/n]"
  read val
  case "$val" in
    Y|y)
      break
      ;;
    N|n)
      echo "N or n was entered. Stopping upgrading process....."
      exit 1
      ;;
  esac
done

# Stop the it.remote.cli service.
echo
echo "Stopping the it.remote.cli service....."
$SUDO remoteit agent stop
if [ $? -ne 0 ]; then
  echo
  echo "Failed to stop the it.remote.cli service."
  echo "Please contact support."
  echo "support@remote.it"
  exit 1
fi

# Uninstall the it.remote.cli service.
echo
echo "Uninstalling the it.remote.cli service....."
$SUDO remoteit agent uninstall
if [ $? -ne 0 ]; then
  echo
  echo "Failed to uninstall the it.remote.cli service."
  echo "Please contact support."
  echo "support@remote.it"
  exit 1
fi

# Copy the latest CLI to bin dir.
$SUDO cp -f "$SCRIPT_DIR/r3_cli_upgrade/tmp/remoteit" $BIN_DIR

# Install and start the latest CLI.
echo
echo "Installing the new Remote.It CLI....."
cd $BIN_DIR
$SUDO remoteit tools install --yes && $SUDO remoteit agent install --yes
if [ $? -ne 0 ]; then
  echo
  echo "Failed to install or start the new it.remote.cli service."
  echo "Start to rollback to the old version."
  rollback
else
  echo
  echo "CLI has been upgraded to $VERSION."
  exit 0
fi
