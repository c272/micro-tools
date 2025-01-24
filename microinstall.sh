#!/usr/bin/env bash

# Script for installing a fresh copy of the micro:bit v2 SDK and setting up micro-tools to use it.
# Can be used when the user does not already have a copy of the micro:bit v2 SDK installed.
# Author: github.com/c272
# License: GPLv3

# Colour code setup.
RED='\033[0;31m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m'
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

# Print version information.
SCRIPT_DIR=$(dirname "$(realpath "$0")")
COMMIT=$(cd "$SCRIPT_DIR" && git rev-parse HEAD)
echo -e "${CYAN}microinstall v0.1 (c) C272, 2022${NC}"
echo -e "${CYAN}revision: ${COMMIT:0:10}${NC}\n"

# Set fail-fast errors to on.
set -e

# Parse arguments passed in directly.
for ARGUMENT in "$@"
do
    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    KEY_LENGTH=${#KEY}
    VALUE="${ARGUMENT:$KEY_LENGTH+1}"
    export "$KEY"="$VALUE"
done

# Install dependencies for the build & setup process.
# Supports Debian-based, Void linux & brew.
echo -e "${CYAN}Installing dependencies for setup & build...${NC}"

# Must check brew before apt, in case apt is installed via. brew...
if [[ -x "$(command -v brew)" ]]; then
    brew install cmake python3 coreutils gnu-sed
    brew install --cask gcc-arm-embedded
elif [[ -x "$(command -v apt)" ]]; then
    sudo apt install git gcc python3 cmake gcc-arm-none-eabi binutils-arm-none-eabi
elif [[ -x "$(command -v xbps-install)" ]]; then
    sudo xbps-install -Su git python3 cmake cross-arm-none-eabi cross-arm-none-eabi-gcc \
    cross-arm-none-eabi-binutils cross-arm-none-eabi-newlib \
    cross-arm-none-eabi-libstdc++
elif [[ -x "$(command -v pacman)" ]]; then
    sudo pacman -S git gcc python3 cmake arm-none-eabi-gcc arm-none-eabi-binutils arm-none-eabi-newlib
elif [[ -x "$(command -v dnf)" ]]; then
    sudo dnf install binutils git gcc gcc-c++ python3 cmake make automake arm-none-eabi-gcc-cs arm-none-eabi-gcc-cs-c++ arm-none-eabi-binutils-cs arm-none-eabi-newlib
else
    echo -e "${RED}Supported package manager (one of: apt, xbps-install, brew) was not found on this system.${NC}"
    exit -1
fi

# If we should only install dependencies, exit here.
if [[ ! -z "$DEPENDENCIES_ONLY" ]]; then
    echo -e "${GREEN}${BOLD}Successfully installed all micro-tools dependencies.${NORMAL}${NC}"
    exit 0
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
./setup.sh "MICROBIT_SDK_DIRECTORY=$SCRIPT_DIR/microbit-v2-sdk"
cd "$ORIGINAL_PWD"
