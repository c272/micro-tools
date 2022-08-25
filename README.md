# micro-tools <img alt="License Badge" align="right" src="https://img.shields.io/github/license/c272/micro-tools"><img alt="Platform Badge" align="right" src="https://img.shields.io/badge/platform-linux-blue">
*A collection of tools to enhance the micro:bit v2 developer experience.*

Welcome to the `micro-tools` repository, a collection of scripts and utilities which improve the quality of life experience for working with the CODAL micro:bit v2 API. There are several tools included in this repository, the most important ones being:

- `microbuild`: Allows for the easy building of micro:bit v2 projects anywhere in your filesystem, removing the need to place your code into the microbit-v2-samples source folder.
- `microinit`: Sets up a micro:bit v2 project directory for Visual Studio Code, configuring the include directories, compiler options and debug settings for the local CODAL API.

The tooling in this repository is purely aimed at Linux distributions, however does not require any heavy dependencies, so should work correctly on Windows under MinGW, however that is not guaranteed, and a use case that this repository will support. These tools are all licensed under the GPLv3, so feel free to fork and contribute changes if you find something worth improving.

## Getting Started 
To get started using `micro-tools`, first clone the repository into a directory with user execute permissions.
```bash
git clone https://github.com/c272/micro-tools.git
cd micro-tools/
```

Once this is done, run the `setup.sh` script found within this folder to configure the location of your micro:bit v2 SDK (where your `microbit-v2-samples` repository is located). This will also create an `aliases.sh` file which defines command aliases for all the scripts contained within the repository. Once this is done, source these aliases in your preferred terminal's `.****rc` file (such as `~/.bashrc`), like so:
```bash
...
source /path/to/micro-tools/aliases.sh
...
```

Now you're good to go! Start a new terminal instance, and you should be able to initialise projects with `microinit` and build with `microbuild`.

## Usage
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