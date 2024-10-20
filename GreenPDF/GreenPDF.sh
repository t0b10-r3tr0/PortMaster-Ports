#!/bin/bash

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

get_controls

CUR_TTY=/dev/tty0

PORTDIR="/$directory/ports"
GAMEDIR="$PORTDIR/green-pdf"

cd $GAMEDIR
$ESUDO chmod 666 $CUR_TTY
$ESUDO touch log.txt
$ESUDO chmod 666 log.txt
export TERM=linux
printf "\033c" > $CUR_TTY



# Test02: fit=none
# echo "Test02: fit=none (waiting 3s...)" > $CUR_TTY
LD_LIBRARY_PATH="$PWD/libs" $TASKSET ./green-pdf 2>&1 | $ESUDO tee -a ./log.txt
@GAMEDIR/gptokeyb "green-pdf" -c green-pdf.gptk g
LD_LIBRARY_PATH=$GAMEDIR/libs ./green-pdf -fullscreen -fit=none $GAMEDIR/test-data/Free_Test_Data_1MB_PDF.pdf 2>&1 | $ESUDO tee -a ./log.txt
$ESUDO kill -9 $(pidof gptokeyb)
unset LD_LIBRARY_PATH
unset SDL_GAMECONTROLLERCONFIG
printf "\033c" > $CUR_TTY

$ESUDO systemctl restart oga_events &

# Disable console
printf "\033c" > $CUR_TTY
#timeout 3s kill $pid