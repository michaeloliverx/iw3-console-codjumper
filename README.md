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

## Usage

This mod is compatible with the following setups:

- Xbox 360 with the ability to run unsigned code (JTAG/RGH/DEVKIT)
- PS3 Jailbroken
- Xenia Emulator
- RPCS3 Emulator

## Build

You need python 3.12+ installed.

To build an Xbox 360 patch_mp.ff run:

```sh
python scripts/build_fastfile_xenon.py
```

Output is `build/xenon/patch_mp.ff`.
