#!/bin/bash
###############################################
# script to initialize budabot repo skeletons #
###############################################

source "~~~HOST_USER_HOME~~~/config.sh"
source "$HOST_DIR/functions.sh"

source "$HOST_DIR/header.sh"

echo "Setting up budabot directory ..."
_mkdir "$TARGET_DIR"
echo -e "${TAB}done.\n"

echo "Initializing repositories ..."
RTAB="$TAB$TAB$TAB"
find "$HOST_DIR" -type d -name "*.repo" | while read REPO_SRC; do
	REPO=`basename $REPO_SRC`
	REPO_DST="$TARGET_DIR/$REPO"
	echo "${TAB}${REPO}:"
	_budabot_skeleton "$REPO_SRC" "$REPO_DST"
	echo "${TAB}${TAB}done."
done || exit $?
RTAB=""
echo -e "${TAB}done.\n"

echo -e "SUCCESS!\n\n"
