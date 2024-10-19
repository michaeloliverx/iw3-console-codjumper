# IW3 Console CodJumper Mod

GSC CodJumper mod for Call of Duty 4.

![Menu preview](./docs/menu-preview.png)

## Features

- Save and load position
- Unlimited ammo with reload animation
- UFO Mode
- Map selector
- Game object manipulations
- Various visual tweaks
- Ability to spawn stationary bots

### Xbox 360 Specific Features

The Xbox 360 version of the mod includes additional features that require engine modifications via a plugin.

- Auto Mantle Bots - Bots will automatically mantle when player is near them. This allows bots to be used for head bounces.
- Barrier Removal - Removes barriers from the map. This allows players to walk on areas that are normally blocked off.

## Usage

This mod is compatible with the following setups:

- Xbox 360 with the ability to run unsigned code (JTAG/RGH/DEVKIT)
- PS3 Jailbroken
- Xenia Emulator
- RPCS3 Emulator

## Build

### Prerequisites

- [uv](https://docs.astral.sh/uv/)
- [make](https://cmake.org/download/)

### Building

To build the fastfiles run:

```sh
make build-all
```

PS3 is `build/ps3/patch_mp.ff`
Xbox 360 is `build/xenon/patch_mp.ff`

### Xbox 360 plugin

The plugin requires additional steps to build and can only be built on Windows.

You need the following tools installed:

- Visual Studio 2022
- Visual Studio 2010
- Microsoft Xbox 360 SDK

To build the plugin run:

```sh
make build-plugin-xenon
```

## Credits

- [ClementDreptin](https://github.com/ClementDreptin) - For his Xbox 360 [modding resources](https://github.com/ClementDreptin/ModdingResources)
- [kejjjjj](https://github.com/kejjjjj) - For answering my many questions on the cod4 engine
- [@luna](https://github.com/luna) - For contributing to the project and help with fastfile build code
- [CoD4x](https://github.com/callofduty4x/CoD4x_Server) - Amazing resource for COD4 modding
