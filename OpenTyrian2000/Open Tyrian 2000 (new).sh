#!/bin/bash

# XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

# if [ -d "/opt/system/Tools/PortMaster/" ]; then
#   controlfolder="/opt/system/Tools/PortMaster"
# elif [ -d "/opt/tools/PortMaster/" ]; then
#   controlfolder="/opt/tools/PortMaster"
# elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
#   controlfolder="$XDG_DATA_HOME/PortMaster"
# else
#   controlfolder="/roms/ports/PortMaster"
# fi

# source $controlfolder/control.txt

# get_controls

# GAMEDIR="/$directory/ports/opentyrian2000"

# $ESUDO chmod 666 /dev/tty1
# $ESUDO chmod 666 /dev/uinput

# cd $GAMEDIR
# $GPTOKEYB "opentyrian2000" -c "opentyrian2000.gptk" &

# # launch game 
# ./opentyrian2000 -t tyrian2000 -j 2>&1 | tee $GAMEDIR/log.txt

# $ESUDO kill -9 $(pidof gptokeyb)
# $ESUDO systemctl restart oga_events &
# printf "\033c" >> /dev/tty1

# Below we assign the source of the control folder (which is the PortMaster folder) based on the distro:
#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt # We source the control.txt file contents here
# The $ESUDO, $directory, $param_device and necessary sdl configuration controller configurations will be sourced from the control.txt file shown [here]

# If a Port is built for armhf architecture only (Need for Speed 2 for example) we set this flag so that some environment condition variables are set in the CFWs mod files.
# Example "https://github.com/PortsMaster/PortMaster-GUI/blob/main/PortMaster/mod_JELOS.txt"
# export PORT_32BIT="Y" # If using a 32 bit port, else comment it out.

# We source custom mod files from the portmaster folder example mod_jelos.txt which containts pipewire fixes
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

# We pull the controller configs like the correct SDL2 Gamecontrollerdb GUID from the get_controls function from the control.txt file here
get_controls

# We switch to the port's directory location below & set the variable for the gamedir and a configuration dir  easier handling below
GAMEDIR=/$directory/ports//
CONFDIR="$GAMEDIR/conf/"

portexecutable=opentyrian2000
portname=opentyrian2000
portfolder=opentyrian2000

# Ensure the conf directory exists
mkdir -p "$GAMEDIR/conf"

# Switch to the game directory
cd $GAMEDIR

# Log the execution of the script, the script overwrites itself on each launch
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Some ports like to create save files or settings files in the user's home folder or other locations. We map these config folders so we can either preconfigure games and or have the savefiles in one place. I
# You can either use XDG variables to redirect the Ports to our gamefolder if the port supports it:

# Set the XDG environment variables for config & savefiles
export XDG_DATA_HOME="$CONFDIR"

# OR  

# Use bind_directories to reroute that to a location within the ports folder.
bind_directories $GAMEDIR/conf/.${portfolder} ~/.${portfolder}

# Port specific additional libraries should be included within the port's directory in a separate subfolder named libs.aarch64, libs.armhf or libs.x64
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"

# Provide appropriate controller configuration if it recognizes SDL controller input
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# If a port uses GL4ES (libgl.so.1) a folder named gl4es.aarch64 etc. needs to be created with the libgl.so.1 file in it. This makes sure that each cfw and device get the correct GL4ES export.
if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

# We launch gptokeyb using this $GPTOKEYB variable as it will take care of sourcing the executable from the central location,
# assign the appropriate exit hotkey dependent on the device (ex. select + start for most devices and minus + start for the 
# rgb10) and assign the appropriate method for killing an executable dependent on the OS the port is run from.
# With -c we assign a custom mapping file else gptokeyb will only run as a tool to kill the process.
# For $ANALOGSTICKS we have the ability to supply multiple gptk files to support 1 and 2 analogue stick devices in different ways.
# For a proper documentation how gptokeyb works: [Link](https://github.com/PortsMaster/gptokeyb)
$GPTOKEYB "${portexecutable}.${DEVICE_ARCH}" -c "./${portname}.gptk.$ANALOGSTICKS" &

# Do some platform specific stuff right before the port is launched but after GPTOKEYB is run.
pm_platform_helper "$GAMEDIR/${portexecutable}.${DEVICE_ARCH}"

# Now we launch the port's executable with multiarch support. Make sure to rename your file according to the architecture you built for. E.g. portexecutable.aarch64
./portexecutable.${DEVICE_ARCH} Launch the executable

# Cleanup any running gptokeyb instances, and any platform specific stuff.
pm_finish