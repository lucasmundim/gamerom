# Gamerom - The Video Game ROM downloader

A command-line installer for game ROMs from many repositories.

It currently supports the following repositories:

  - https://vimm.net
  - https://coolrom.com.au
  - https://www.romnation.net

## Installation

### Using Docker

Add this to your .bashrc, .bash_aliases, etc:

```
alias gamerom="docker run -e UID=$(id -u) -e GROUP_ID=$(id -g) --rm -it -v ~/.gamerom:/home/runuser/.gamerom docker.io/lucasmundim/gamerom:0.3.0"
```

Use it as:

```
gamerom help
```

### Using Rubygems

Install it as a regular gem:

    $ gem install gamerom

Use it as:

```
gamerom help
```

### Using Git

Clone, cd into, bundle install, and bundle exec:

    $ git clone git@github.com:lucasmundim/gamerom.git
    $ cd rom/
    $ bundle install

Use it as:

    $ bundle exec ./exe/gamerom help

## Usage

### help

```
$ gamerom help
Commands:
  gamerom config                                                             # Show config
  gamerom help [COMMAND]                                                     # Describe available commands or one specific command
  gamerom info GAME_IDENTIFIER -p, --platform=PLATFORM -r, --repo=REPO       # Info for game GAME_IDENTIFIER (id/name)
  gamerom install GAME_IDENTIFIER -p, --platform=PLATFORM -r, --repo=REPO    # Install game GAME_IDENTIFIER (id/name)
  gamerom install_all -p, --platform=PLATFORM -r, --repo=REPO                # Install all games
  gamerom list -p, --platform=PLATFORM -r, --repo=REPO                       # List available games
  gamerom platforms -r, --repo=REPO                                          # List available platforms
  gamerom recover -p, --platform=PLATFORM -r, --repo=REPO                    # Try to recover state from already downloaded roms
  gamerom regions -p, --platform=PLATFORM -r, --repo=REPO                    # List available regions
  gamerom repo                                                               # List available repo
  gamerom search KEYWORD -p, --platform=PLATFORM -r, --repo=REPO             # Search games by KEYWORD
  gamerom stats -p, --platform=PLATFORM -r, --repo=REPO                      # Show platform stats
  gamerom stats_all -r, --repo=REPO                                          # Show stats for all platforms
  gamerom uninstall GAME_IDENTIFIER -p, --platform=PLATFORM -r, --repo=REPO  # Uninstall game GAME_IDENTIFIER (id/name)
  gamerom uninstall_all -p, --platform=PLATFORM -r, --repo=REPO              # Uninstall all games
  gamerom update_all_databases -r, --repo=REPO                               # Update all local databases
  gamerom update_database -p, --platform=PLATFORM -r, --repo=REPO            # Update local database
  gamerom version                                                            # Print program version

Options:
  -v, [--verbose], [--no-verbose]  # Show verbose backtrace
```

### repo

List available repo

```
$ gamerom repo
listing available repo...
coolrom
romnation
vimm
```

### platforms

List available platforms

```
$ gamerom platform --repo coolrom
listing available platforms for coolrom repo...
---
:platforms:
  atari2600: Atari 2600
  atari5200: Atari 5200
  atari7800: Atari 7800
  atarijaguar: Atari Jaguar
  atarilynx: Atari Lynx
  c64: Commodore 64
  cps1: CPS1
  cps2: CPS2
  mame: MAME
  namcosystem22: Namco System 22
  neogeo: Neo Geo
  neogeocd: Neo Geo CD
  neogeopocket: Neo Geo Pocket
  segacd: Sega CD
  dc: Sega Dreamcast
  gamegear: Sega Game Gear
  genesis: Sega Genesis
  mastersystem: Sega Master System
  model2: Sega Model 2
  saturn: Sega Saturn
  psx: Sony Playstation
  ps2: Sony Playstation 2
  psp: Sony Playstation Portable
```

```
$ gamerom platforms -r romnation
listing available platforms for romnation repo...
---
:platforms:
  amstrad: Amstrad
  atari2600: Atari 2600
  atari5200: Atari 5200
  atari7800: Atari 7800
  atarijaguar: Atari Jaguar
  atarilynx: Atari Lynx
  colecovision: ColecoVision
  commodore64: Commodore 64
  gamegear: Game Gear
  gb: Game Boy
  gbc: Game Boy Color
  gcdvectrex: Vectrex
  genesis: Genesis
  intellivision: Intellivision
  mame: MAME
  msx1: MSX
  msx2: MSX2
  mtx: MTX
  n64: N64
  neogeocd: Neo Geo CD
  neogeopocket: Neo Geo Pocket
  nes: NES
  oric: Oric
  pce: PC Engine
  radioshackcolorcomputer: TRS-80
  samcoupe: SAM Coupé
  segacd: Sega CD
  segamastersystem: Master System
  snes: SNES
  thompsonmo5: Thomson MO5
  virtualboy: Virtual Boy
  watara: Watara Supervision
  wonderswan: WonderSwan
```

```
$ gamerom platform -r vimm
listing available platforms for vimm repo...
---
:platforms:
  Dreamcast: Dreamcast
  DS: Nintendo DS
  GameCube: GameCube
  GB: Game Boy
  GBA: Game Boy Advance
  GBC: Game Boy Color
  Genesis: Genesis
  N64: Nintendo 64
  NES: Nintendo
  PS1: PlayStation
  PS2: PlayStation 2
  PS3: PlayStation 3
  PSP: PlayStation Portable
  Saturn: Saturn
  SNES: Super Nintendo
  Wii: Wii
  WiiWare: WiiWare
```

### list

List available games

```
$ gamerom list -r coolrom -p namcosystem22
listing available games for namcosystem22 platform on coolrom repo...
ID   NAME           REGION  INSTALLED           TAGS
316  Rave Racer     USA     installed  -
318  Ridge Racer 2  USA     installed  -
```

Filtering by region:
```
$ gamerom list -r coolrom -p model2 -g Japan
listing available games for model2 platform on coolrom repo...
ID     NAME                               REGION  INSTALLED  TAGS
12952  Virtual On Cyber Troopers (Japan)  Japan   -          -
12956  Zero Gunner (Japan Model 2B)       Japan   -          -
```

### search

Search games by KEYWORD

```
$ gamerom search -r romnation -p segamastersystem "Alex Kidd in Shinobi World"
searching available games for segamastersystem platform on romnation repo...
ID     NAME                                  REGION  INSTALLED  TAGS
39126  Alex Kidd in Shinobi World (UE) [!]   USA     -          good
39127  Alex Kidd in Shinobi World (UE) [b1]  USA     -          bad
39128  Alex Kidd in Shinobi World (UE) [b2]  USA     -          bad
```

### regions

List available regions

```
$ gamerom regions -r coolrom -p genesis
listing available regions for genesis platform on coolrom repo...
Australia
Brazil
China
Europe
France
Germany
Japan
Korea
Spain
Sweden
USA
```

### install

Install game GAME_IDENTIFIER (id/name)

```
$ gamerom install -r vimm -p NES 'Mega Man'
installing game 545 - Mega Man - USA on NES platform on vimm repo...
downloading single file rom
http://download4.vimm.net/download/?mediaId=530
100% |ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo|  74.8KB  46.3KB/s Time: 00:00:01
Game installed
```

### install_all

Install all games

```
$ gamerom install_all -r coolrom -p genesis -g Brazil
installing game 48155 - Duke Nukem 3D (Brazil) - Brazil on genesis platform on coolrom repo...
http://dl.coolrom.com.au/dl/48155/5dK3T--nRZaY8u4PI5T8cA/1621206423/
100% |ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo| 871.7KB 947.8KB/s Time: 00:00:00
Game installed
installing game 6501 - Ferias Frustradas do Pica-Pau (Brazil) - Brazil on genesis platform on coolrom repo...
http://dl.coolrom.com.au/dl/6501/ZRVwx6lSpE6lRovr9xyEdg/1621206427/
100% |ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo| 383.1KB 679.3KB/s Time: 00:00:00
Game installed
installing game 6358 - Mega Games 10 (Brazil) - Brazil on genesis platform on coolrom repo...
http://dl.coolrom.com.au/dl/6358/kjK-Zsuc0pr0JEqvG_G80Q/1621206429/
100% |ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo|   2.6MB   1.1MB/s Time: 00:00:02
Game installed
installing game 47766 - Phantasy Star II (Brazil) - Brazil on genesis platform on coolrom repo...
http://dl.coolrom.com.au/dl/47766/wH66hX5V4j3oShDXn511NA/1621206434/
100% |ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo| 455.1KB 602.7KB/s Time: 00:00:00
Game installed
installing game 5683 - Sega Top Five (Brazil) - Brazil on genesis platform on coolrom repo...
http://dl.coolrom.com.au/dl/5683/2DjilMgmxbTPShCju0uCiA/1621206436/
100% |ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo|   1.2MB 998.2KB/s Time: 00:00:01
Game installed
installing game 47898 - Show do Milhao (Brazil) - Brazil on genesis platform on coolrom repo...
http://dl.coolrom.com.au/dl/47898/_T8xacEEtXt1iYsFG6MzFw/1621206439/
100% |ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo|   1.2MB 931.3KB/s Time: 00:00:01
Game installed
installing game 47909 - Show do Milhao Volume 2 (Brazil) - Brazil on genesis platform on coolrom repo...
http://dl.coolrom.com.au/dl/47909/O8MHNPxxA6bd3TMyaa7x_g/1621206442/
100% |ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo|   1.2MB 776.2KB/s Time: 00:00:01
Game installed
installing game 47747 - Sport Games (Brazil) - Brazil on genesis platform on coolrom repo...
http://dl.coolrom.com.au/dl/47747/9Ne0wIsVUErFiMNWURrjsQ/1621206445/
100% |ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo| 745.7KB 693.8KB/s Time: 00:00:01
Game installed
installing game 5552 - Telebradesco Residencia (Brazil) - Brazil on genesis platform on coolrom repo...
http://dl.coolrom.com.au/dl/5552/Ne3f6ZBFQSGN-SXMPRWwgw/1621206448/
100% |ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo|  48.6KB 270.2KB/s Time: 00:00:00
Game installed
installing game 5808 - Turma da Monica na Terra dos Monstros (Brazil) - Brazil on genesis platform on coolrom repo...
http://dl.coolrom.com.au/dl/5808/iOJ8k5sD7SVnbh_FtXyAWQ/1621206450/
100% |ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo| 546.2KB 268.1KB/s Time: 00:00:02
Game installed
installing game 48020 - Where in the World Is Carmen Sandiego (Brazil) - Brazil on genesis platform on coolrom repo...
http://dl.coolrom.com.au/dl/48020/p5HRSrsXvU_3GfO9-C1I0w/1621206453/
100% |ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo| 713.7KB 336.5KB/s Time: 00:00:02
Game installed
installing game 47824 - Where in Time Is Carmen Sandiego (Brazil) - Brazil on genesis platform on coolrom repo...
http://dl.coolrom.com.au/dl/47824/iNkVLfIiFm30d5mPyRIO6g/1621206457/
100% |ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo| 631.7KB 332.4KB/s Time: 00:00:01
Game installed
installing game 47770 - Yuu Yuu Hakusho - Sunset Fighters (Brazil) - Brazil on genesis platform on coolrom repo...
http://dl.coolrom.com.au/dl/47770/lygKB0n14EGKCmQkd_lHuw/1621206460/
100% |ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo|   1.1MB 345.3KB/s Time: 00:00:03
Game installed
```

### uninstall

Uninstall game GAME_IDENTIFIER (id/name)

```
$ gamerom uninstall -r coolrom -p gamegear 7493
uninstalling game 7493 - Zoop - USA on gamegear platform...
Game uninstalled
```

### uninstall_all

Uninstall all games

```
$ gamerom uninstall_all -r coolrom -p gamegear
uninstalling game 7274 - 007 James Bond - The Duel - USA on gamegear platform...
Game uninstalled
uninstalling game 7414 - 5 in 1 Funpak - USA on gamegear platform...
Game uninstalled
uninstalling game 7545 - Addams Family - USA on gamegear platform...
Game uninstalled
```

### info

Info for game GAME_IDENTIFIER (id/name)

```
$ gamerom info -r coolrom -p atari2600 adventure
showing info for game adventure on atari2600 platform on coolrom repo...
15913 - Adventure - USA (installed)
/Users/lucas/.gamerom/games/coolrom/atari2600/USA/Adventure.zip
```

### update_database

Update local database

```
$ gamerom update_database -r coolrom -p atari2600
updating atari2600 platform on coolrom repo...
atari2600:     100% |oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo| Time: 00:00:13
Game database updated for platform atari2600 on coolrom repo
```

### update_all_databases

Update all local databases

```
$ gamerom update_all_databases -r coolrom
updating all databases on coolrom repo...
atari2600:     100% |oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo| Time: 00:00:11
atari5200:     100% |oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo| Time: 00:00:10
atari7800:     100% |oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo| Time: 00:00:10
atarijaguar:   100% |oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo| Time: 00:00:11
atarilynx:     100% |oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo| Time: 00:00:11
c64:           100% |oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo| Time: 00:00:23
cps1:          100% |oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo| Time: 00:00:10
cps2:          100% |oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo| Time: 00:00:11
mame:          100% |oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo| Time: 00:01:20
namcosystem22: 100% |oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo| Time: 00:00:10
neogeo:        100% |oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo| Time: 00:00:11
neogeocd:      100% |oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo| Time: 00:00:11
neogeopocket:  100% |oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo| Time: 00:00:10
segacd:        100% |oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo| Time: 00:00:11
dc:            100% |oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo| Time: 00:00:12
gamegear:      100% |oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo| Time: 00:00:11
genesis:       100% |oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo| Time: 00:00:14
mastersystem:  100% |oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo| Time: 00:00:11
model2:        100% |oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo| Time: 00:00:11
saturn:        100% |oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo| Time: 00:00:11
psx:           100% |oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo| Time: 00:00:21
ps2:           100% |oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo| Time: 00:00:17
psp:           100% |oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo| Time: 00:00:16
All game databases updated
```

### stats

Show platform stats

```
$ gamerom stats -r coolrom -p gamegear
stats for gamegear platform on coolrom repo...
  All: 4/337 - size: 440K
  Japan: 0/45 - size: 0
  USA: 4/292 - size: 440K
```

### stats_all

Show stats for all platforms

```
$ gamerom stats_all -r coolrom
stats for atari2600 platform on coolrom repo...
  All: 645/645 - size: 3.6M
  USA: 645/645 - size: 3.6M

stats for atari5200 platform on coolrom repo...
  All: 94/94 - size: 1.2M
  USA: 94/94 - size: 1.2M

stats for atari7800 platform on coolrom repo...
  All: 58/58 - size: 2.0M
  USA: 58/58 - size: 2.0M

stats for atarijaguar platform on coolrom repo...
  All: 44/44 - size: 85M
  USA: 44/44 - size: 85M

stats for atarilynx platform on coolrom repo...
  All: 85/85 - size: 12M
  USA: 85/85 - size: 12M

stats for c64 platform on coolrom repo...
  All: 0/5649 - size: 0
  Germany: 0/2 - size: 0
  Spain: 0/9 - size: 0
  USA: 0/5638 - size: 0

stats for cps1 platform on coolrom repo...
  All: 24/24 - size: 49M
  USA: 24/24 - size: 49M

stats for cps2 platform on coolrom repo...
  All: 32/32 - size: 472M
  USA: 32/32 - size: 472M

stats for mame platform on coolrom repo...
  All: 22/29668 - size: 16M
  Australia: 0/6 - size: 0
  Brazil: 22/22 - size: 16M
  Canada: 0/5 - size: 0
  China: 0/47 - size: 0
  Europe: 0/48 - size: 0
  France: 0/136 - size: 0
  Germany: 0/230 - size: 0
  Italy: 0/174 - size: 0
  Japan: 0/1556 - size: 0
  Korea: 0/112 - size: 0
  Netherlands: 0/195 - size: 0
  Norway: 0/2 - size: 0
  Russia: 0/95 - size: 0
  Spain: 0/179 - size: 0
  Sweden: 0/2 - size: 0
  USA: 0/26859 - size: 0

stats for namcosystem22 platform on coolrom repo...
  All: 1/2 - size: 21M
  USA: 1/2 - size: 21M

stats for neogeo platform on coolrom repo...
  All: 125/125 - size: 1.5G
  USA: 125/125 - size: 1.5G

stats for neogeocd platform on coolrom repo...
  All: 94/94 - size: 5.1G
  USA: 94/94 - size: 5.1G

stats for neogeopocket platform on coolrom repo...
  All: 0/87 - size: 0
  USA: 0/87 - size: 0

stats for segacd platform on coolrom repo...
  All: 147/147 - size: 14G
  USA: 147/147 - size: 14G

stats for dc platform on coolrom repo...
  All: 0/262 - size: 0
  USA: 0/262 - size: 0

stats for gamegear platform on coolrom repo...
  All: 4/337 - size: 440K
  Japan: 0/45 - size: 0
  USA: 4/292 - size: 440K

stats for genesis platform on coolrom repo...
  All: 990/1615 - size: 637M
  Australia: 0/1 - size: 0
  Brazil: 13/13 - size: 12M
  China: 0/8 - size: 0
  Europe: 10/243 - size: 6.1M
  France: 0/4 - size: 0
  Germany: 0/5 - size: 0
  Japan: 10/373 - size: 4.4M
  Korea: 0/7 - size: 0
  Spain: 0/2 - size: 0
  Sweden: 0/2 - size: 0
  USA: 957/957 - size: 615M

stats for mastersystem platform on coolrom repo...
  All: 309/309 - size: 43M
  USA: 309/309 - size: 43M

stats for model2 platform on coolrom repo...
  All: 23/25 - size: 355M
  Japan: 0/2 - size: 0
  USA: 23/23 - size: 355M

stats for saturn platform on coolrom repo...
  All: 0/133 - size: 0
  USA: 0/133 - size: 0

stats for psx platform on coolrom repo...
  All: 84/5025 - size: 20G
  Australia: 0/1 - size: 0
  Europe: 0/796 - size: 0
  France: 0/30 - size: 0
  Germany: 0/156 - size: 0
  Italy: 0/21 - size: 0
  Japan: 0/2147 - size: 0
  Russia: 0/3 - size: 0
  Spain: 0/36 - size: 0
  USA: 84/1835 - size: 20G

stats for ps2 platform on coolrom repo...
  All: 0/3173 - size: 0
  Australia: 0/85 - size: 0
  China: 0/2 - size: 0
  Europe: 0/1170 - size: 0
  France: 0/25 - size: 0
  Germany: 0/100 - size: 0
  Italy: 0/18 - size: 0
  Japan: 0/219 - size: 0
  Korea: 0/8 - size: 0
  Netherlands: 0/1 - size: 0
  Russia: 0/1 - size: 0
  Spain: 0/47 - size: 0
  Sweden: 0/2 - size: 0
  USA: 0/1495 - size: 0

stats for psp platform on coolrom repo...
  All: 0/2808 - size: 0
  Australia: 0/4 - size: 0
  China: 0/91 - size: 0
  Europe: 0/609 - size: 0
  France: 0/43 - size: 0
  Germany: 0/45 - size: 0
  Italy: 0/35 - size: 0
  Japan: 0/1189 - size: 0
  Korea: 0/107 - size: 0
  Netherlands: 0/6 - size: 0
  Norway: 0/2 - size: 0
  Russia: 0/21 - size: 0
  Spain: 0/37 - size: 0
  Sweden: 0/3 - size: 0
  USA: 0/616 - size: 0
```

### config

Show config

```
$ gamerom config
{:ROM_ROOT=>"/Users/lucas/.gamerom",
 :CACHE_DIR=>"/Users/lucas/.gamerom/cache",
 :GAME_DIR=>"/Users/lucas/.gamerom/games",
 :LOG_DIR=>"/Users/lucas/.gamerom/logs"}
```

### version

Print program version

```
$ gamerom version
0.3.0
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/lucasmundim/gamerom. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/lucasmundim/gamerom/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Gamerom project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/lucasmundim/gamerom/blob/master/CODE_OF_CONDUCT.md).
