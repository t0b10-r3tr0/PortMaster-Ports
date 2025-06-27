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

source $controlfolder/control.txt

#export PORT_32BIT="Y" # If using a 32 bit port
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

GAMEDIR=/$directory/ports/pcem
CONFDIR="$GAMEDIR/conf/"
PORT_NAME="PCem"
PORT_EXECUTABLE="pcem"


mkdir -p "$GAMEDIR/conf"

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Weston begins
weston_dir=/tmp/weston
weston_runtime="weston_pkg_0.2"
if [ ! -f "$controlfolder/libs/${weston_runtime}.squashfs" ]; then
    if [ ! -f "$controlfolder/harbourmaster" ]; then
        pm_message "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info."
        sleep 5
        exit 1
    fi
    $ESUDO $controlfolder/harbourmaster --quiet --no-check runtime_check "${weston_runtime}.squashfs"
fi
$ESUDO mkdir -p "${weston_dir}"
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${weston_dir}"
fi
$ESUDO mount "$controlfolder/libs/${weston_runtime}.squashfs" "${weston_dir}"
# Weston ends

export XDG_DATA_HOME="$CONFDIR"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
#export TEXTINPUTINTERACTIVE="Y"

# if XDG Path does not work
# Use bind_directories to reroute that to a location within the ports folder.
bind_directories ~/.pcem $GAMEDIR/conf/.pcem

# If using gl4es
#if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
#  source "${controlfolder}/libgl_${CFW_NAME}.txt"
#else
#  source "${controlfolder}/libgl_default.txt"
#fi

$GPTOKEYB "$PORT_EXECUTABLE"."$DEVICE_ARCH" -c "./$PORT_NAME.gptk.$ANALOGSTICKS" &
pm_platform_helper "$GAMEDIR"/"$PORT_EXECUTABLE"."${DEVICE_ARCH}"
# ./"$PORT_EXECUTABLE"."${DEVICE_ARCH}"
$ESUDO env $weston_dir/westonwrap.sh drm auto desktop crusty_x11egl ./"$PORT_EXECUTABLE"."${DEVICE_ARCH}"
$ESUDO env WRAPPED_LIBRARY_PATH=/your/custom/libraries/ SOME_VAR=$SOME_OTHER_VAR $weston_dir/westonwrap.sh headless noop kiosk crusty_glx_gl4es VAR_PASSED_TO_APP=SOME_VALUE ./"$PORT_EXECUTABLE"."${DEVICE_ARCH}" # --your_arg 123
pm_finish