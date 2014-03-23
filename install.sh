source ./config.sh
source $INSTALL_DIR/functions.sh

source $INSTALL_DIR/header.sh

echo "Processing requirements ..."
_install ${REQUIRED_PACKAGES[@]}
echo -e "${TAB}done.\n"

echo "Processing user and group ..."
if [ "$HOST_USER_NAME" == "$HOST_GROUP_NAME" ]; then
	if ! id -u "$HOST_USER_NAME" > /dev/null 2> /dev/null;  then
		adduser "$HOST_USER_NAME" || _error Could not create user "'$HOST_USER_NAME'"
	fi
else
	_error Different user name and group name not supported yet	
fi
echo -e "${TAB}done.\n"

echo "Setting up repositories ..."
RTAB="${TAB}${TAB}${TAB}${TAB}"
find "$INSTALL_REPO_DIR" -type f -name "*.repo" | while read REPO_SCRIPT; do
	REPO=`basename "$REPO_SCRIPT"`
	REPO_DIR="$HOST_USER_HOME/$REPO"
	echo "${TAB}${TAB}Installing $REPO ..."
	source "$REPO_SCRIPT"
	echo "${TAB}${TAB}${TAB}done."
done || exit $?
RTAB=""
echo -e "${TAB}done.\n"

echo "Installing chat proxy ..."
PROXY_DIR="$HOST_USER_HOME/proxy"
# getting files
_zip_install http://budabot2.googlecode.com/files/aochatproxy1.1.zip "$PROXY_DIR" 1
echo -e "${PROXY_PORT_BASE}\n" > "$PROXY_DIR/port.base"
touch "$PROXY_DIR/port.list"
# set permissions
_chmod_rec "$PROXY_DIR"
_chmod_script "$PROXY_DIR/start.sh"
chmod 660 "$PROXY_DIR/port.list"
echo -e "${TAB}done.\n"

echo "Preparing scripts ..."
find "$INSTALL_SCRIPTS_DIR" -maxdepth 1 -type f -name "*.sh" | while read file; do
	file=`basename "$file"`
	cp "$INSTALL_SCRIPTS_DIR/$file" "$HOST_USER_HOME/$file"
done
find "$INSTALL_SCRIPTS_DIR/tpl" -type f -name "*.sh" | while read file; do
	file=`basename "$file"`
	_cp_tpl "$INSTALL_SCRIPTS_DIR/tpl/$file" "$HOST_USER_HOME/$file"
done || exit $?
cp "$INSTALL_DIR/functions.sh" "$HOST_USER_HOME/functions.sh"
cp "$INSTALL_DIR/header.sh" "$HOST_USER_HOME/header.sh"
find "$HOST_USER_HOME" -maxdepth 1 -type f -name "*.sh" -print0 | xargs -0 chmod $HOST_SCRIPT_MASK
#chmod 750 "$HOST_USER_HOME/*.sh"
echo -e "${TAB}done.\n"

echo "Setting owner and owning group ..."
chown -R $HOST_USER_NAME:$HOST_GROUP_NAME "$HOST_USER_HOME"
echo -e "${TAB} done.\n"

echo -e "SUCCESS!\n\n"
