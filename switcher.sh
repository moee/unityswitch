#!/bin/bash
# unity-workspace-switcher
#
# Setup
# Time between workspace transition in seconds. It might be needed to adjust this depending on the machine's performance
SLEEPTIME_TRANSITION=1
# Time each workspace is shown
SLEEPTIME_SCREEN=5
# Transition sequence order
ORDER=("Right" "Down" "Left" "Up");
# Expected workspace sizes for the given transition sequence order to work. This will be checked when the script gets called.
EXPECTED_HSIZE=2
EXPECTED_VSIZE=2

# This file will be created when the scripts starts an endless loop. if you delete it, the script will terminate
PIDFILE=/tmp/switcher.pid

# A file that contains a command for each workspace in a separate line
COMMANDSFILE=commands.txt

if [ -z $1 ];
    then
    echo "usage: $0 [start|stop]"
    exit
fi

if [ "$1" == "stop" ];
    then
    if [ ! -f $PIDFILE ];
    then
        echo $0 is not running
        exit 1
    fi
    pkill $0
    kill `cat $PIDFILE`
    rm $PIDFILE
    exit 0
fi

if [ ! -f $COMMANDSFILE ];
    then
        echo The file with the commands expected in $COMMANDSFILE does not exist.
        exit 1
    fi

if [ -f $PIDFILE ];
then
    echo $0 is already running. stop with \"$0 stop\"
    exit 1
fi

while read line
do
    COMMANDS+=("$line")
done < $COMMANDSFILE

# Check if this is an unity desktop and if it has  the correct workspace layout.
HSIZE=$(gsettings get org.compiz.core:/org/compiz/profiles/unity/plugins/core/ hsize)
VSIZE=$(gsettings get org.compiz.core:/org/compiz/profiles/unity/plugins/core/ vsize)

if [ $HSIZE != $EXPECTED_HSIZE ] || [ $VSIZE != $EXPECTED_VSIZE ]
    then
    echo "This script expects a workspace vsize of $EXPECTED_VSIZE and hsize of $EXPECTED_HSIZE"
    exit 1;
fi

function switcher() {
    echo $$ > $PIDFILE

    # calibrate, i.e. make sure we start in the top left workspace
    xdotool key super+s
    sleep $SLEEPTIME_TRANSITION
    for KEY in ${ORDER[@]}
    do
        xdotool key $KEY
    done
    sleep $SLEEPTIME_TRANSITION
    xdotool key Return
    sleep $SLEEPTIME_TRANSITION

    # first cycle: run all commands
    i=0
    for KEY in ${ORDER[@]}
    do
        xdotool key super+s
        sleep $SLEEPTIME_TRANSITION
        xdotool key $KEY
        sleep $SLEEPTIME_TRANSITION 
        xdotool key Return
        sleep $SLEEPTIME_TRANSITION
        `${COMMANDS[$i]}`
        i=$[i + 1]
        sleep $SLEEPTIME_SCREEN
    done

    while [ -f $PIDFILE ] ;
    do
        for KEY in ${ORDER[@]}
        do
            xdotool key super+s
            sleep $SLEEPTIME_TRANSITION
            xdotool key $KEY
            sleep $SLEEPTIME_TRANSITION
            xdotool key Return
            if [ ! -f $PIDFILE ];
            then
                exit 0
            fi
            sleep $SLEEPTIME_SCREEN
        done
    done
}

# fork off process
if [ "$1" == "start" ];
    then
    switcher &
fi
