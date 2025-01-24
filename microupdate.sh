#!/usr/bin/env bash
set -e

# A utility script to update all SDK repositories for micro:bit v2.
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
echo -e "${CYAN}microupdate v0.1 (c) C272, 2022${NC}"
echo -e "${CYAN}revision: ${COMMIT:0:10}${NC}\n"

# Run the configuration script.
if [ -f "$SCRIPT_DIR/config.sh" ]; then
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

# If "MICROBIT_SDK_DIRECTORY" does not exist, error out.
if [[ -z "$MICROBIT_SDK_DIRECTORY" ]]; then
  	echo -e "${RED}The micro:bit v2 SDK directory was not specified. Either specify this in \`config.sh\`, or via the MICROBIT_SDK_DIRECTORY=... parameter.${NC}"
  	exit -1
fi

# Get absolute path of microbit SDK directory, ensure it has a build.py.
MICROBIT_SDK_DIRECTORY=$(realpath "$MICROBIT_SDK_DIRECTORY")
if [[ ! -f "$MICROBIT_SDK_DIRECTORY/build.py" ]]; then
  	echo -e "${RED}No 'build.py' file was found in provided SDK directory ('$MICROBIT_SDK_DIRECTORY'). Are you sure this is a valid micro:bit SDK directory?${NC}"
	exit -1
fi

# Update micro-tools.
ORIGINAL_PWD=$PWD
cd $SCRIPT_DIR
echo -e "${CYAN}\nUpdating micro-tools to latest master...${NC}"
git remote update
GIT_STATUS=$(git status -uno)
if [[ $GIT_STATUS =~ "Your branch is up to date"  ]]; then
	echo -e "${CYAN}No update required for micro-tools.${NC}"
else
	# If we need an update, run the setup script again.
	git pull
	./setup.sh
	echo -e "${GREEN}${BOLD}\nFinished updating micro-tools.${NORMAL}${NC}"
fi

# Update SDK files.
echo -e "${CYAN}\nUpdating all micro:bit v2 repositories...${NC}"
cd $MICROBIT_SDK_DIRECTORY
python3 build.py --update
cd $ORIGINAL_PWD
echo -e "${GREEN}${BOLD}Finished updating micro:bit v2 repositories.${NORMAL}${NC}"

echo -e "${GREEN}${BOLD}Finished updates!${NORMAL}${NC}"