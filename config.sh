HOST_USER_NAME=budabot
HOST_USER_HOME=/home/budabot
HOST_GROUP_NAME=budabot

HOST_DIR_MASK=770
HOST_FILE_MASK=640
HOST_SCRIPT_MASK=750

INSTALL_DIR=~/budahost
INSTALL_SCRIPTS_DIR=$INSTALL_DIR/scripts
INSTALL_REPO_DIR=$INSTALL_DIR/repos

REQUIRED_PACKAGES=(php5-cli php5-mysql php5-sqlite screen openjdk-7-jre mysql-server git wget unzip)

PORT_BASE=17250

TAB="    "
RTAB=""
