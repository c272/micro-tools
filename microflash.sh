#!/usr/bin/env bash
set -e

# A utility script to make flashing micro:bit projects to the micro:bit v2 on Linux
# a little bit easier.
# Author: github.com/c272
# License: GPLv3

# Colour code setup.
RED='\033[0;31m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m'
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

######################
## HELPER FUNCTIONS ##
######################

# Unmounts the micro:bit from the current mount directory.
unmount_microbit() {
    # Ensure directory is a mount point.
    if grep -qs "$MICROBIT_MOUNT_DIR " /proc/mounts; then
        sudo umount $MICROBIT_MOUNT_DIR
    else
        echo -e "${RED}Nothing was mounted at the micro:bit mount directory ('$MICROBIT_MOUNT_DIR'), exiting.${NC}"
        exit -1
    fi
}

# Mounts the micro:bit at the configured mount directory.
mount_microbit() {
    # Ensure we're not already mounted.
    if grep -qs "$MICROBIT_MOUNT_DIR " /proc/mounts; then
        echo -e "${CYAN}The micro:bit was already mounted, unmounting for re-mount...${NC}"
        unmount_microbit
    fi
    sudo mount "$MICROBIT_DEVPATH" "$MICROBIT_MOUNT_DIR"
}

################
## ENTRYPOINT ##
################

# Print version information.
SCRIPT_DIR=$(dirname "$(realpath "$0")")
COMMIT=$(cd $SCRIPT_DIR && git rev-parse HEAD)
echo -e "${CYAN}microflash v0.1 (c) C272, 2022${NC}"
echo -e "${CYAN}revision: ${COMMIT:0:10}${NC}\n"

# Run the configuration script.
if [[ -f "$SCRIPT_DIR/config.sh" ]]; then
    echo "Running configuration script..."
    source "$SCRIPT_DIR/config.sh"
fi

# Parse arguments passed in directly.
for ARGUMENT in "$@"
do
    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    KEY_LENGTH=${#KEY}
    VALUE="${ARGUMENT:$KEY_LENGTH+1}"
    export "$KEY"="$VALUE"
done

# Error out if no mount directory is specified.
if [[ -z "$MICROBIT_MOUNT_DIR" ]]; then
    echo -e "${RED}No micro:bit mount directory specified. Pass MICROBIT_MOUNT_DIR as a command line argument, or set a default value in config.sh.${NC}"
    exit -1
fi

# Make the mount directory relative to micro-tools if provided as non-absolute.
if [[ $MICROBIT_MOUNT_DIR != "/*" ]]; then
    MICROBIT_MOUNT_DIR="$SCRIPT_DIR/$MICROBIT_MOUNT_DIR"
fi
echo "Mount directory specified as $MICROBIT_MOUNT_DIR."

# Make the mount directory in the tools directory, if it doesn't exist.
mkdir -p "$MICROBIT_MOUNT_DIR"

# Get micro:bit storage mount /dev/ device, ensure it exists.
MICROBIT_DEVPATH="/dev/disk/by-label/MICROBIT"
if [[ ! -L "$MICROBIT_DEVPATH" ]]; then
    echo -e "${RED}No micro:bit was detected as a /dev/ device. Are you sure it is connected?${NC}"
    exit -1
fi

# If we just get an mount/unmount request, try and do that.
if [[ ! -z "$DO_UNMOUNT" ]]; then
    echo -e "${CYAN}Attempting to unmount the micro:bit...${NC}"
    unmount_microbit
    echo -e "${GREEN}${BOLD}Successfully unmounted the micro:bit.${NORMAL}${NC}"
    exit 0
fi
if [[ ! -z "$DO_MOUNT" ]]; then
    echo -e "${CYAN}Attempting to mount the micro:bit...${NC}"
    mount_microbit
    echo -e "${GREEN}${BOLD}Successfully mounted the micro:bit.${NORMAL}\n${NC}"
    exit 0
fi

# Error out if the hex file is unspecified/does not exist.
if [[ -z "$MICROBIT_HEX_FILE" ]]; then
    echo -e "${RED}No micro:bit hex file specified to flash. Pass MICROBIT_HEX_FILE as a command line argument, or set a default value in config.sh.${NC}"
    exit -1
fi
if [[ ! -f "$MICROBIT_HEX_FILE" ]]; then
  echo -e "${RED}The micro:bit hex file provided to flash, '$MICROBIT_HEX_FILE', does not exist.${NC}"
  exit -1
fi

# Get the real path of the file.
MICROBIT_HEX_FILE=$(realpath "$MICROBIT_HEX_FILE")

# Re-mount the micro:bit.
echo -e "${CYAN}Mounting micro:bit at '$MICROBIT_MOUNT_DIR'...${NC}"
mount_microbit
echo -e "${GREEN}${BOLD}Successfully mounted the micro:bit.${NORMAL}\n${NC}"

# Copy target hex file onto device.
echo -e "${CYAN}Copying target hex file onto device...${NC}"
sudo /bin/cp -rf $MICROBIT_HEX_FILE "$MICROBIT_MOUNT_DIR/MICROBIT.hex"

# Unmount to trigger flash.
echo -e "${CYAN}Performing flash...${NC}"
unmount_microbit

echo -e "${GREEN}${BOLD}Flashing complete!${NORMAL}${NC}"