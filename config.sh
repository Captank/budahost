#!/bin/bash
##############################################
# script to store installation configuration #
##############################################

# defines the user name for the budabot host system
HOST_USER_NAME=budabot
# defines the home directory of the user = directory of the budabot host system
HOST_USER_HOME=/home/budabot
# defines the group name for the budabot host syste,
HOST_GROUP_NAME=budabot

# default mask for directories
HOST_DIR_MASK=770
# default mask for files
HOST_FILE_MASK=640
# default mask for scripts
HOST_SCRIPT_MASK=750

# location of the install scripts
INSTALL_DIR=~/budahost
# location of the scripts to copy
INSTALL_SCRIPTS_DIR=$INSTALL_DIR/scripts
# location of the repository install scripts
INSTALL_REPO_DIR=$INSTALL_DIR/repos

# all required packages
REQUIRED_PACKAGES=(php5-cli php5-mysql php5-sqlite screen openjdk-7-jre mysql-server git wget unzip)

# start port for the port handler
PORT_BASE=17250

# some stuff for text indention for the scripts
TAB="    "
RTAB=""
