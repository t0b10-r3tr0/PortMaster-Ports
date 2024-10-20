# Currently being refactored. It is recommended that you wait until a better version is built.
## I am working on making some changes that will hopefully fix things. I will do better in the future.
# &nbsp;
## Thank you @JohnnyonFlame for making such a great Port.
# &nbsp;
## Built for retro handhelds, powered by PortMaster!

### Overview<img align="right" width="100" height="100" src="media/shovel-knight.gif">

This is a script that extends a **PortMaster port* for **Shovel Knight: Treasure Trove** originally created by [JohnnyonFlame](https://github.com/johnnyonFlame/). This port extension (script) supports the following standalone versions of Shovel Knight's adventures:

- [Shovel Knight: Shovel of Hope](https://shovelknight.fandom.com/wiki/Shovel_Knight:_Shovel_of_Hope)
- [Shovel Knight: Specter of Torment](https://shovelknight.fandom.com/wiki/Shovel_Knight:_Specter_of_Torment)
- [Shovel Knight: King of Cards](https://shovelknight.fandom.com/wiki/Shovel_Knight:_King_of_Cards)
- [Shovel Knight Showdown](https://shovelknight.fandom.com/wiki/Shovel_Knight_Showdown)

### Requirements

This script requires the Linux version executables and game data from each of the four supported games. If you own it on Steam or GoG, you already own these and just have to download them. The GoG version is fairly straight forward, the Steam version requires you to use the command line. I will post instructions soon.

### Installation instructions

1. Download the release package, located at: [ShovelKnight-SE.zip](https://github.com/t0b10-t3nm4/PortablePorts/raw/main/Release/Shovel%20Knight-SE.zip)
1. On your device, locate the **ports** directory (usually within the **roms** directory) and unzip the file you just downloaded right there.
1. You should now have the following two items in your ports folder:
   - `Shovel Kinght SE.sh`
   - `shovelknight-se` (in this one is `gamedata`, which you'll soon need)
1. From the the Linux version of for standalone game(s) you are installing, locate the following 3 directories: '32', '64', and 'data'. These 3 directories will go into the subdirectory of the `gamedata` directory as mentioned above that match the name of your game(s).
1. verify that the directory structure as defined in `gamedata/instructions.txt/` matches yours, and copy the the 3 directories.
1. Using **Shovel of Hope** as an exmaple, if you've done it correctly, you should have placed your files similar to the following: `ports/shovelknight-se/gamedata/shovelofhope` and in that location you should see the `32`, `64`, and `data` directories from the game.
1. If you've made it this far, celebrate because you're through through the hardest part.
1. Reboot your device unless you manually copied them with the device off.
1. From your Ports location, launch the game!

### Troubleshooting

There will be a log file (`log.txt`) within the directory where the port was installed that contains some useful information should you run into trouble. Good luck and if you can't solve it by verifying your game files with the `instructions.txt` directions under `gamedata`, reach out to me in this channel or somebody, myself included, in the PortMaster channel.

### Acknowledgements

I couldn't have any of this without the original work created by Johnny and my desire the help of @Kloptops who both very graciously let me use their own creations as an instrument for my learning. Please support the original creator [JohnnyonFlame](https://github.com/johnnyonFlame), and [kloptops](https://github.com/kloptops) for what they do for the community. There are also many others, who are owed a huge thank you.
