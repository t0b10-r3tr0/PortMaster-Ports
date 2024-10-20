#!/bin/bash
# PORTMASTER: carrion.zip, Carrion.sh

# Port by t0b10

# Enable verbose mode for debugging
 set -xv
_DEBUG="on" 

function DEBUG()
{
 [ "$_DEBUG" == "on" ] &&  "$@"
}

function to_lowercase() {
    local input="$1"
    echo "${input,,}"
}

function stop_with_reason() {
    echo "$1" 2>&1 | tee -a $LOG_FILE
    $ESUDO kill -9 $(pidof gptokeyb)
    $ESUDO systemctl restart oga_events &
    printf "\033c" > $CUR_TTY
}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
get_controls

# Define the base directory for the games
GAMEDIR="/$directory/ports/carrion"
GAMEDATADIR="$GAMEDIR/gamedata"

# Output vonrtolas
CUR_TTY=/dev/tty0
LOG_FILE=$GAMEDIR/log.txt

$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/tty1
printf "\033c" > /dev/tty0
printf "\033c" > /dev/tty1

echo "Loading... Please wait. (1/2)" > /dev/tty0

# No more user input required
$ESUDO kill -9 $(pidof gptokeyb)
printf "\033c" > $CUR_TTY

DEBUG echo "begin games launch." 2>&1 | tee -a $LOG_FILE

# Change to selected game directory
cd "$GAMEDATADIR" || stop_with_reason "EXIT: Executable dir not found."
DEBUG echo "Attempting launch from: $GAMEDATADIR"

# Environment setup
export LIBGL_NOBANNER=1
export LIBGL_ES=2
export LIBGL_GL=21
export LIBGL_FB=4
export BOX64_LOG=2
export LD_LIBRARY_PATH=$GAMEDIR/box64/lib:$GAMEDIR/box64/native:/usr/lib:$GAMEDATADIR
export BOX64_LD_LIBRARY_PATH=$GAMEDIR/box64/lib:$GAMEDIR/box64/native:/usr/lib/:./:lib/:lib/:x64/
export BOX64_DYNAREC=1
export SDL_GAMECONTROLLERCONFIG=$sdl_controllerconfig

$ESUDO rm -rf ~/.steam
$ESUDO rm -rf ~/.local/share/Steam

$ESUDO ln -s $GAMEDIR/steam/.steam ~/.steam
$ESUDO ln -s $GAMEDIR/steam/.local/share/Steam ~/.local/share/Steam

# $ESUDO rm -rf ~/.local/share/Yacht\ Club\ Games
# $ESUDO ln -s $GAMEDIR/Yacht\ Club\ Games ~/.local/share/

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "box64" -c "$GAMEDIR/carrion.gptk" &

echo "Loading... Please wait. (2/2)" > /dev/tty0

## LD_LIBRARY_PATH="$(pwd):$LD_LIBRARY_PATH" ./$1

$GAMEDIR/box64/box64 Carrion 2>&1 | tee -a $LOG_FILE

stop_with_reason "END: Port was stopped. Exiting."

# Cleanup complete, unless you crashed
unset SDL_GAMECONTROLLERCONFIG
unset LD_LIBRARY_PATH
printf "\033c" >> /dev/tty1
printf "\033c" >> /dev/tty0