#!/usr/bin/env bash
set -e

# Utility script to create a fresh micro:bit v2 project environment, with the appropriate VSCode
# include directories, from an empty/new folder.
# Author: github.com/c272
# License: GPLv3

# Colour code setup.
RED='\033[0;31m'
NC='\033[0m'

# Run the configuration script.
SCRIPT_DIR=$(dirname "$(realpath "$0")")
if [[ -f "$SCRIPT_DIR/config.sh" ]]; then
    source "$SCRIPT_DIR/config.sh"
fi

# If the directory parameter (first parameter) doesn't exist, assume current directory.
if [[ -z "$1" ]]; then
    INIT_DIRECTORY=$1
else
    INIT_DIRECTORY="."
fi
mkdir -p "$INIT_DIRECTORY"

# Parse other arguments passed in directly.
for ARGUMENT in "${@:2}"
do
    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    KEY_LENGTH=${#KEY}
    VALUE="${ARGUMENT:$KEY_LENGTH+1}"
    export "$KEY"="$VALUE"
done

# If "MICROBIT_SDK_DIRECTORY" is not defined or does not exist, error out.
if [[ ! -n "$MICROBIT_SDK_DIRECTORY" ]]; then
  echo -e "${RED}The micro:bit v2 SDK directory was not specified. Either specify this in \`config.sh\`, or via the MICROBIT_SDK_DIRECTORY=... parameter.${NC}"
  exit -1
fi

# Ensure both directories exist.
if [[ ! -d "$MICROBIT_SDK_DIRECTORY" ]]; then
  echo -e "${RED}The micro:bit v2 SDK directory provided ('$MICROBIT_SDK_DIRECTORY') does not exist.${NC}"
  exit -1
fi

# Get the real path of the SDK.
MICROBIT_SDK_DIRECTORY=$(realpath $MICROBIT_SDK_DIRECTORY)

# Get real path of target directory, microinit resources.
INIT_DIRECTORY=$(realpath "$INIT_DIRECTORY")
MICROINIT_RESOURCES_DIR=$SCRIPT_DIR/microinit

# If there is already a Visual Studio config folder for this directory, error out.
INIT_DIR_VSCODE="$INIT_DIRECTORY/.vscode"
if [[ -d "$INIT_DIR_VSCODE" ]]; then
    echo -e "${RED}A .vscode directory already exists within the given init directory.${NC}"
    exit -1
fi

# Create the .vscode directory, copy in the C/C++ properties JSON file.
mkdir -p "$INIT_DIR_VSCODE"
cp "$MICROINIT_RESOURCES_DIR/c_cpp_properties.json" "$INIT_DIR_VSCODE"

# Replace all instances of "$MICROBIT_SDK_DIRECTORY" inside the file with the real directory.
sed -i -e "s%\$MICROBIT_SDK_DIRECTORY%$MICROBIT_SDK_DIRECTORY%g" "$INIT_DIR_VSCODE/c_cpp_properties.json"