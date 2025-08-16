# Pokémon Red and Blue

This is a disassembly of Pokémon Red and Blue.

It builds the following roms:

* Pokemon Red (UE) [S][!].gb  `md5: 3d45c1ee9abd5738df46d2bdda8b57dc`
* Pokemon Blue (UE) [S][!].gb `md5: 50927e843568814f7ed45ec4f944bd8b`

To set up the repository, see [**INSTALL.md**](INSTALL.md).

## Channel mask

At build time you can force the NR51 channel mixing mask with the `CH_MASK`
variable. If it is not specified, a default mask of `0x22` (left and right
channel 2 only) is used. For compatibility, setting `CH2_ONLY=1` has the same
effect as `CH_MASK=0x22`.

Examples:

```
make CH_MASK=0x22    # CH2 only
make CH_MASK=0x11    # CH1 only
make CH_MASK=0x44    # CH3 only
make CH_MASK=0x88    # CH4 only
make CH_MASK=0x02    # CH2 right only
make CH_MASK=0x20    # CH2 left only
```


## Features

- Force the NR51 channel mask at build time
- Optional strict mute, soft panning, and runtime channel masking
- Optional on-screen NR51 mask display

## Build

```
make CH_MASK=0x22 STRICT_MUTE=1 SOFT_PAN=1
make md5
make pdb GB2PDB=tools/gb2pdb.py PDB_TITLE="PokeJP CH2"
```

## Runtime Controls

When built with `RUNTIME_MASK=1`:

- SELECT+LEFT = CH1, RIGHT = CH2, UP = CH3, DOWN = CH4
- SELECT+START = All Mute, SELECT+A = All On
- `SHOW_MASK=1` displays the NR51 mask (hex) in the upper-left corner

## Make targets

- `make`
- `make clean`
- `make md5`
- `make pdb`
- `make run`
- `make zip`

## CI & Releases

[![Build](https://github.com/OWNER/REPO/actions/workflows/build.yml/badge.svg)](https://github.com/OWNER/REPO/actions/workflows/build.yml)

Tags matching `v*` trigger an automatic GitHub Release.

## See also

* Disassembly of [**Pokémon Crystal**][pokecrystal]
* irc: **irc.freenode.net** [**#pret**][irc]

[pokecrystal]: https://github.com/kanzure/pokecrystal
[irc]: https://kiwiirc.com/client/irc.freenode.net/?#pret
