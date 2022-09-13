# micro-tools <img alt="License Badge" align="right" src="https://img.shields.io/github/license/c272/micro-tools"><img alt="Platform Badge" align="right" src="https://img.shields.io/badge/platform-linux-blue">
*A collection of tools to enhance the micro:bit v2 developer experience.*

Welcome to the `micro-tools` repository, a collection of scripts and utilities which improve the quality of life experience for working with the CODAL micro:bit v2 API. There are several tools included in this repository, the most important ones being:

- `microinit`: Sets up a micro:bit v2 project directory for Visual Studio Code, configuring the include directories, compiler options and debug settings for the local CODAL API.
- `microbuild`: Allows for the easy building of micro:bit v2 projects anywhere in your filesystem, removing the need to place your code into the microbit-v2-samples source folder.
- `microflash`: Facilitates the mounting, unmounting, and flashing of the micro:bit v2 in a distro-compatible way, removing the need to fiddle with manually mounting and copying to the micro:bit.

The tooling in this repository is purely aimed at Linux distributions, however does not require any heavy dependencies, so should work correctly on Windows under MinGW, however that is not guaranteed, and not a use case that this repository will support. These tools are all licensed under the GPLv3, so feel free to fork and contribute changes if you find something worth improving.

## Getting Started 
To get started using `micro-tools`, first clone the repository into a directory with user execute permissions.
```bash
git clone https://github.com/c272/micro-tools.git
cd micro-tools/
```

Once this is done, if you have **not** yet downloaded a local copy of the micro:bit v2 samples repository, you can simply run `microinstall.sh` to install and set up everything automatically.
```
./microinstall.sh
```

If this is not the case, and you already have a local copy of the samples repository, run the `setup.sh` script found at the root of the repository to configure the location of your micro:bit v2 SDK (where your `microbit-v2-samples` repository is located). This will also create an `aliases.sh` file which defines command aliases for all the scripts contained within the repository. 

Once either of these steps are complete, you should be prompted to source an alias script file. Place the provided command in your preferred terminal's `.****rc` file (such as `~/.bashrc`), like so:
```bash
...
source /path/to/micro-tools/aliases.sh
...
```

Now you're good to go! Start a new terminal instance, and you should be able to initialise projects with `microinit` and build with `microbuild`.

## Usage
### microinstall
This tool allows you to install the SDK from scratch, without having cloned anything else but this repository. After cloning this, you can simply run:
```
./microinstall.sh
```
And the SDK will be downloaded, installed, and configured to work with the rest of the tools & utilities in this suite. This only supports distributions with either the `apt` package manager (Debian, Ubuntu, Pop!_OS and other Debian-based) or the `xbps-install` package manager (Void Linux). This tool also isn't added as an alias, as you'll likely only want to use it once.

### microinit
This tool allows you to set up Visual Studio Code configurations for a micro:bit v2 project, to allow you to access the APIs with Visual Studio Code's code completion and Intellisense features without the need to be inside the `microbit-v2-samples` folder, as well as the ability to automatically run `microbuild` from within Visual Studio Code's interface. To start a new project with `microinit`, do the following:
```bash
microinit my-project-name
```

This will create a folder named "my-project-name", containing the appropriate VSCode configuration for your system.
Alternatively, if you already have a project directory, you can simply specify the directory name and it will perform setup there. For instance, to initialise in the current directory:
```bash
microinit .
```
Once this is done, you should be able to launch VSCode and see that include paths are properly resolved, and you can build with `microbuild` through Visual Studio Code's build system.

### microbuild
This tool allows for the building of micro:bit v2 projects outside of the `microbit-v2-samples` source folder. To build the default directory (found in `config.sh`, by default this is simply the current directory '`.`'), simply run:
```bash
microbuild
```

To specify a directory to build when running the command, you can add the argument `BUILD_DIRECTORY` with the desired folder. In addition, you can specify the output directory of the `MICROBIT.hex` file with the `BUILD_OUTPUT_DIRECTORY` argument. Most arguments in `micro-tools` are specified with a key-value format, like so:
```
microbuild BUILD_DIRECTORY=./src BUILD_OUTPUT_DIRECTORY=./bin
```
This would take `src` as the source project to build, and `bin` as the destination for the `MICROBIT.hex` file.

### microflash
This tool allows for the flashing of built micro:bit v2 projects to the micro:bit. By default, `microflash` will search for a file named `MICROBIT.hex` in the executing directory (this can be configured in `config.h` or passed in as the command line parameter `MICROBIT_HEX_FILE`), and flash this onto the microbit once mounted. You can perform this with simply:
```bash
microflash
```

The first time the micro:bit is flashed, it is mounted to a directory on the filesystem. By default, this is `mnt/microbit` within the scripts directory, however you can configure this directory in `config.sh` or pass it in as the command line option `MICROBIT_MOUNT_DIR`. If you want to just mount or unmount the micro:bit without performing a flash for whatever reason, you can simply pass the `DO_MOUNT` and `DO_UNMOUNT` arguments respectively to `microflash` like so:
```bash
microflash DO_UNMOUNT=true # Unmounts the micro:bit from the system, then exits.
microflash DO_MOUNT=true # Mounts the micro:bit to the mount directory, then exits.
```

### config.sh
There is a global configuration file "`config.sh`", which can be found at the root of the `micro-tools` directory which specifies default options for all of the utilities within `micro-tools`. It also defines the global location of the micro:bit v2 SDK (the `microbit-v2-samples` repository clone). If you wish to move the SDK somewhere else, you must let `micro-tools` know about the new location of the SDK, otherwise all utilities will stop working. You can do this by editing the global config value `MICROBIT_SDK_DIRECTORY`, like so:
```bash
####################
## Global Options ##
####################

# Location of the micro:bit v2 SDK (as cloned from microbit-v2-samples).
export MICROBIT_SDK_DIRECTORY=/path/to/my/microbit-v2-samples
...
```