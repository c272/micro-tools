#!/usr/bin/env bash

# Script to set up all of the "micro" tools (microbuild, microinit) onto PATH, with a valid SDK installation.
# Author: github.com/c272
# License: GPLv3

# Colour code setup.
RED='\033[0;31m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m'

# Print version information.
SCRIPT_DIR=$(dirname "$(realpath "$0")")
COMMIT=$(cd "$SCRIPT_DIR" && git rev-parse HEAD)
echo -e "${CYAN}micro-tools setup v0.1 (c) C272, 2022${NC}"
echo -e "${CYAN}revision: ${COMMIT:0:10}${NC}\n"

# Set fail-fast errors to on.
set -e

# Darwin-specific setup.
# If we find GNU sed, alias sed to it. MacOS sed has strange parameter requirements.
if [[ -x "$(command -v gsed)" ]]; then
    sed() {
        gsed "$@"
    }
fi

# Parse arguments passed in directly.
for ARGUMENT in "$@"
do
    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    KEY_LENGTH=${#KEY}
    VALUE="${ARGUMENT:$KEY_LENGTH+1}"
    export "$KEY"="$VALUE"
done

# Ask for the directory containing the micro:bit v2 SDK, if it's not provided as an argument.
if [[ -z ${MICROBIT_SDK_DIRECTORY+x} ]]; then
    echo "Enter the location of the micro:bit v2 SDK, as cloned from the 'microbit-v2-samples' repository:"
    read MICROBIT_SDK_DIRECTORY
fi

# Ensure that this directory does exist, and does contain the SDK.
if [[ ! -d "$MICROBIT_SDK_DIRECTORY" ]]; then
  echo -e "${RED}The micro:bit v2 SDK directory provided ('$MICROBIT_SDK_DIRECTORY') does not exist.${NC}"
  exit -1
fi
if [[ ! -f "$MICROBIT_SDK_DIRECTORY/build.py" ]]; then
  echo -e "${RED}No 'build.py' file was found in provided SDK directory ('$MICROBIT_SDK_DIRECTORY'). Are you sure this is a valid micro:bit SDK directory?${NC}"
  exit -1
fi

# Set this in the 'config.sh' file.
echo -e "${CYAN}Updating config with SDK directory...${NC}"
sed -i -e "s%# export MICROBIT_SDK_DIRECTORY=%export MICROBIT_SDK_DIRECTORY=\"$MICROBIT_SDK_DIRECTORY\"%g" "$SCRIPT_DIR/config.sh"

# Create the aliases file.
echo -e "${CYAN}Creating aliases for micro-tools scripts...${NC}"
ESCAPED_SCRIPT_DIR="${SCRIPT_DIR// /\\ }"
cat > "$SCRIPT_DIR/aliases.sh" << EOF
alias microbuild="$ESCAPED_SCRIPT_DIR/microbuild.sh"
alias microinit="$ESCAPED_SCRIPT_DIR/microinit.sh"
alias microupdate="$ESCAPED_SCRIPT_DIR/microupdate.sh"
alias microflash="$ESCAPED_SCRIPT_DIR/microflash.sh"
EOF
sudo chmod +x "$SCRIPT_DIR/aliases.sh"

# Setup complete! Instruct user to add the alias setup script to their .**rc file.
echo -e "\n${GREEN}Setup complete! Add the following to your terminal's startup file (eg. '~/.bashrc') to add micro-tools to your PATH:${NC}"
echo -e "\t${GREEN}source ${SCRIPT_DIR}/aliases.sh${NC}"