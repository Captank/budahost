#!/bin/bash
##############################
# test script for port stuff #
##############################

source "~~~HOST_USER_HOME~~~/config.sh"
source "$HOST_DIR/functions.sh"

source "$HOST_DIR/header.sh"

_register_port "$HOME/nightly.repo/conf/captestbot.sqlite.php#proxy" || exit $?
echo the port is: $REGISTERED_PORT
