#!/bin/bash
# PORTMASTER: shovelknight.se.zip, Shovel Knight - SE.sh

# original port by JohnnyonFlame, this just extends it to support the stand-alone games.
# https://github.com/JohnnyonFlame/BoxofPatches

# Enable verbose mode for debugging
# set -xv
# _DEBUG="on" 

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
GAMEDIR="/$directory/ports/shovelknight-se"
GAMEDATADIR="$GAMEDIR/gamedata"

# Output vonrtolas
CUR_TTY=/dev/tty0
LOG_FILE=$GAMEDIR/log.txt

$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/tty1
printf "\033c" > /dev/tty0
printf "\033c" > /dev/tty1

echo "Detecting game data, please wait... (Shouldn't be too long)" > /dev/tty0

# Define the game directories and names
declare -A games
games=(
    ["ShovelOfHope"]="Shovel of Hope"
    ["SpecterOfTorment"]="Specter of Torment"
    ["KingOfCards"]="King of Cards"
    ["ShovelKnightShowdown"]="Shovel Knight Showdown"
)

# Check for installed games
installed_games=()
for game in "${!games[@]}"; do
    if [ -f "$GAMEDATADIR/$game/64/$game" ]; then
        installed_games+=("$game")
    fi
done

printf "\e[?25h" > $CUR_TTY
dialog --clear > $CUR_TTY

# allow control for upcoming user choices
$GPTOKEYB "dialog" -c "${GAMEDIR}/shovelknight-menu.gptk" &

# If no games are installed, display an error message and exit
if [ ${#installed_games[@]} -eq 0 ]; then
    dialog --title "Error" --msgbox "No games are detected. Please refer to insructions.txt in gamedata directory." 7 40 > $CUR_TTY
    stop_with_reason "EXIT: No games detected."
    exit 1
fi

# Create a menu using dialog
CMD=(dialog --title "Game Selection" --menu "Select your desired game:" 12 40 ${#installed_games[@]})
i=1
for game in "${installed_games[@]}"; do
    CMD+=("$i" "${games[$game]}")
    (("i += 1"))
done

choice=$("${CMD[@]}" 2>&1 >$CUR_TTY)
  if [ $? != 0 ]; then
        stop_with_reason "QUIT: $choice"
        exit 1;
      fi
# Subtract 1 from the choice
((choice -= 1))

# No more user input required
$ESUDO kill -9 $(pidof gptokeyb)
printf "\033c" > $CUR_TTY

DEBUG echo "begin games launch." 2>&1 | tee -a $LOG_FILE

# Retrieve the game directory / binary from the choice
selected_game_dir="$(to_lowercase "${installed_games[$choice]}")"
selected_binary="${installed_games[$choice]}"

# Print the selected game, binary, and game directory
DEBUG echo "Selected '${games[$game]}' with binary '$selected_binary' (64 bit) in game directory '$selected_game_dir'." 2>&1 | tee -a $LOG_FILE

# Change to selected game directory
cd "$GAMEDATADIR/$selected_game_dir/64" || stop_with_reason "EXIT: Executable dir not found."
DEBUG echo "Attempting launch from: $GAMEDATADIR/$selected_game_dir/64"

# Environment setup
export LIBGL_NOBANNER=1
export LIBGL_ES=2
export LIBGL_GL=21
export LIBGL_FB=4
export BOX64_LOG=1
export BOX64_LD_PRELOAD=$GAMEDIR/libShovelKnight.so
export LD_LIBRARY_PATH=$GAMEDIR/box64/lib:$GAMEDIR/box64/native:/usr/lib:/usr/lib
export BOX64_LD_LIBRARY_PATH=$GAMEDIR/box64/lib:$GAMEDIR/box64/native:/usr/lib/:./:lib/:lib/:x64/
export BOX64_DYNAREC=1
export SDL_GAMECONTROLLERCONFIG=$sdl_controllerconfig

$ESUDO rm -rf ~/.local/share/Yacht\ Club\ Games
$ESUDO ln -s $GAMEDIR/Yacht\ Club\ Games ~/.local/share/
$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "box64" -c "$GAMEDIR/shovelknight.gptk" &

echo "Loading, please wait... (Shouldn't be too long)" > /dev/tty0

# Replace the exisiting binary with the standalone version, load, and remove
$ESUDO cp -rf $selected_binary ShovelKnight 2>&1 | tee -a $LOG_FILE
$GAMEDIR/box64/box64 ShovelKnight 2>&1 | tee -a $LOG_FILE
$ESUDO rm -rf ShovelKnight

stop_with_reason "END: Port was stopped. Exiting."

# Cleanup complete, unless you crashed
unset SDL_GAMECONTROLLERCONFIG
unset LD_LIBRARY_PATH
printf "\033c" >> /dev/tty1
printf "\033c" >> /dev/tty0