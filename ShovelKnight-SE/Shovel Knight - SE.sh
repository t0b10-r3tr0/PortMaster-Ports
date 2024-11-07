#!/bin/bash

# original port by JohnnyonFlame, this just extends support for the stand-alone version(s) of the GAME(s).
# https://github.com/JohnnyonFlame/BoxofPatches

function stop_with_reason() {
  # Log exit reason and call pm_finish
  echo "$1" 2>&1 | tee -a $LOG_FILE
  pm_finish
}

function to_lowercase() {
    local input="$1"
    echo "${input,,}"
}

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

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

# Define the base directory for the GAMES
GAMEDIR="/$directory/ports/shovelknightse"
GAMEDATADIR="$GAMEDIR/gamedata"

GAMEDIRNAME="shovelknightse"
GAMEDATADIRNAME="gamedata"
GAMEDIR="/$directory/ports/$GAMEDIRNAME"
CONFDIR="$GAMEDIR/conf/"
CONFDIRNAME=Yacht\ Club\ Games
BINARY=ShovelKnight

# Output vonrtolas
CUR_TTY=/dev/tty0
LOG_FILE=$GAMEDIR/log.txt

$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/tty1
printf "\033c" > /dev/tty0
printf "\033c" > /dev/tty1

# Define the GAME directories and names
declare -A GAMES
GAMES=(
    ["ShovelOfHope"]="Shovel of Hope"
    ["SpecterOfTorment"]="Specter of Torment"
    ["KingOfCards"]="King of Cards"
    ["ShovelKnightShowdown"]="Shovel Knight Showdown"
)

# Check for installed GAMES
INSTALLED_GAMES=()
for GAME in "${!GAMES[@]}"; do
    if [ -f "$GAMEDIR/gamedata/$GAME/32/$GAME" ]; then
        INSTALLED_GAMES+=("$GAME")
    fi
done

# allow control for upcoming user choices
printf "\e[?25h" > $CUR_TTY
dialog --clear > $CUR_TTY
$GPTOKEYB "dialog" -c "${GAMEDIR}/$BINARY-menu.gptk" &

# If no GAMES are installed, display an error message and exit
if [ ${#INSTALLED_GAMES[@]} -eq 0 ]; then
    dialog --title "Error" --msgbox "No GAMES are detected. Please refer to insructions.txt in gamedata directory." 7 40 > $CUR_TTY
    stop_with_reason "EXIT: No GAMES detected."
    exit 1
fi

# Create a menu using dialog
CMD=(dialog --title "Game Selection" --menu "Select your desired GAME:" 12 40 ${#INSTALLED_GAMES[@]})
i=1
for GAME in "${INSTALLED_GAMES[@]}"; do
    CMD+=("$i" "${GAMES[$GAME]}")
    (("i += 1"))
done

# capture the choice and handle the quit
CHOICE=$("${CMD[@]}" 2>&1 >$CUR_TTY)
  if [ $? != 0 ]; then
        stop_with_reason "QUIT: User did not proceed."
        exit 1;
  fi

# No longer need user input for dialog
$ESUDO kill -9 $(pidof gptokeyb)
printf "\033c" > $CUR_TTY

# Subtract 1 from the choice
((CHOICE -= 1))

# Retrieve the GAME directory / binary from the choice
SELECTED_GAMEDIR="$(to_lowercase "${INSTALLED_GAMES[$CHOICE]}")"
SELECTED_BINARY="${INSTALLED_GAMES[$CHOICE]}"

# Print the selected GAME, binary, and GAME directory
echo "Now loading $SELECTED_BINARY! Please wait..." > /dev/tty0

# change to selected GAME directory
cd "$GAMEDATADIR/$SELECTED_GAMEDIR/32" || stop_with_reason "EXIT: Executable directory not found."

export LIBGL_NOBANNER=1
export LIBGL_ES=2
export LIBGL_GL=21
export LIBGL_FB=4
export BOX86_LOG=0
export BOX86_LD_PRELOAD=$GAMEDIR/libShovelKnight.so
export LD_LIBRARY_PATH=$GAMEDIR/box86/lib:$GAMEDIR/box86/native:/usr/lib:/usr/lib32
export BOX86_LD_LIBRARY_PATH=$GAMEDIR/box86/lib:$GAMEDIR/box86/native:/usr/lib32/:./:lib/:lib32/:x86/
export BOX86_DYNAREC=1
export SDL_GAMECONTROLLERCONFIG=$sdl_controllerconfig

# Remove the conf dir if it exists, then bind to our port's conf dir
$ESUDO rm -rf ~/.local/share/$CONFDIRNAME
bind_directories ~/.local/share/$CONFDIRNAME $GAMEDIR/conf/$CONFDIRNAME

$GPTOKEYB "box86" -c "$GAMEDIR/$BINARY.gptk" &

if [[ ! -e $BINARY ]]; then
  $ESUDO cp -rf $SELECTED_BINARY ShovelKnight 2>&1 | tee -a $LOG_FILE
fi

$GAMEDIR/box86/box86 ShovelKnight 2>&1 | tee -a $LOG_FILE

stop_with_reason "END: Port was stopped. Exiting."