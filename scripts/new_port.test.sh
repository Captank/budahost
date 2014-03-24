#!/bin/bash
##############################
# test script for port stuff #
##############################

source /home/budabot/config.sh
source "$HOST_DIR/functions.sh"

source "$HOST_DIR/header.sh"

_register_port "$HOME/nightly.repo/conf/captestbot.sqlite.php#proxy" || exit $?
echo the port is: $REGISTERED_PORT
