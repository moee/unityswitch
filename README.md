unityswitch
===========
This script switches the workspace on an ubuntu unity desktop.

This was made for a kiosk mode display that should display the content of four websites and switch between them periodically.

Tested with Ubuntu 12.10 on a Unity desktop with 4 virtual desktops in a 2x2 grid.

Feel free to adapt the script to your own needs - You probably will have to do this anyway. However, use entirely at your own risk. It's still a bit buggy.

## Setup
Create a file called commands.txt and put it into the directory of the workspace switcher. This file contains a line for each command that should be executed once upon startup in each workspace. A sample file that opens four firefox windows is provided in `commands.txt.sample`.

You can also adjust some settings in `switcher.sh` (like timer settings).

## Usage
switcher.sh [start|stop]

Warning: Stopping the script can become a bit tricky. So the best tactic is to run ./switcher.sh stop is either from a (remote ssh) shell and not via the GUI.
