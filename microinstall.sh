#!/usr/bin/env bash
set -e

# Script for installing a fresh copy of the micro:bit v2 SDK and setting up micro-tools to use it.
# Can be used when the user does not already have a copy of the micro:bit v2 SDK installed.
# Author: github.com/c272
# License: GPLv3

# Colour code setup.
RED='\033[0;31m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m'

# Print version information.
SCRIPT_DIR=$(dirname "$(realpath "$0")")
COMMIT=$(cd $SCRIPT_DIR && git rev-parse HEAD)
echo -e "${CYAN}microinstall v0.1 (c) C272, 2022${NC}"
echo -e "${CYAN}revision: ${COMMIT:0:10}${NC}\n"

# Install dependencies for the build & setup process.
# Supports Debian-based & Void linux.
echo -e "${CYAN}Installing dependencies for setup & build...${NC}"
if [[ -x "$(command -v apt)" ]]; then
    sudo apt install git gcc python3 cmake gcc-arm-none-eabi binutils-arm-none-eabi
elif [[ -x "$(command -v xbps-install)" ]]; then
    sudo xbps-install -Su git python3 cmake cross-arm-none-eabi cross-arm-none-eabi-gcc \
    cross-arm-none-eabi-binutils cross-arm-none-eabi-newlib \
    cross-arm-none-eabi-libstdc++
else
    echo -e "${RED}Supported package manager (one of: apt, xbps-install) was not found on this system.${NC}"
    exit -1
fi

# Clone the samples repository.
echo -e "${CYAN}Cloning 'microbit-v2-samples' from upstream...${NC}"
ORIGINAL_PWD=$PWD
SDK_DIRECTORY="$SCRIPT_DIR/microbit-v2-sdk"
cd "$SCRIPT_DIR"
if [[ -d $SDK_DIRECTORY ]]; then
    sudo rm -r "$SDK_DIRECTORY" # Ensure directory is wiped before clone.
fi
git clone https://github.com/lancaster-university/microbit-v2-samples.git microbit-v2-sdk/

# Verify that the "Hello World" compiles.
echo -e "${CYAN}Setting up SDK & verifying 'Hello World' compile...${NC}"
cd microbit-v2-sdk/
python3 build.py

# Run the setup script to set up aliases, passing in the directory.
cd "$SCRIPT_DIR"
./setup.sh MICROBIT_SDK_DIRECTORY=$SCRIPT_DIR/microbit-v2-sdk
cd $ORIGINAL_PWD