#Budahost

#NOTE: THE SYSTEM IS NOT READY YET, DON'T USE IT YET!

##About

Budahost is a bunch of bash scripts (and a PHP script) to set up a budabot host system on linux systems, to avoid multiple installations of the same version of budabot.

##Requirements
- Linux distribution as OS
- bash
- dpkg-l
- apt
- root access

##Usage
###System install
1. Download and extract the files or clone the repository to the directory /root/budahost (the install.sh must have the absolute path /root/budahost/install.sh)
2. You can configurate the install by editing /root/budahost/config.sh 
3. run cd /root/budahost && chmod u+x install && install.sh
4. Follow given instructions

This will install all required packages (like php-cli and some other stuff), adds a new user and group, install a nightly build of budabot (it clones the repository) and also installs a stable build (currently that's budabot 3.0 GA), adds the RULES_MODULE as user module to both builds, installs the aochatproxy (that's currently version 1.1) and provides some scripts for the bot handling

###Setting up a bot system
1. Add the new user and add it to the host group
2. Run the init.sh in the host directory to create a skeleton
3. Run ~/budabot/create_bot.sh <repo> <configname> to create a bot
4. If you need a proxy for that bot run ~/budabot/setup_proxy.sh <repo> <configname>
5. If you want to use the API\_MODULE use ~/budabot/setup_api.sh <repo> <cofnigname> to get a new API port
6. Then you can use ~/budabot/bots.sh start to start all bots that are not running yet

##Files documentation
###install.sh
Main installation file

###config.sh
Configuration file for the install routine

###functions.sh
Scrip file that declares all functions

###header.sh
Simple script file to print the header

###replace.php
PHP script to replace placeholders of script templates and write the result to a destionation file


###repos/*.repo
Script files to install budabot builds, their file name is also the name of the build

###scripts/*.sh
Templated script files for the host system
