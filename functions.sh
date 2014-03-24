#!/bin/bash
#########################################
# script to define all needed functions #
#########################################

if ! type _error > /dev/null 2> /dev/null; then
	# function for formated error message
	# all parameters are simply printed separated by a space
	# breaks the script always
	function _error {
		echo -e "${RTAB}ERROR! ${@}!\n\nFAILED!\n\n"
		exit 1
	}
fi

if ! type _install > /dev/null 2> /dev/null; then
	# function to install packages if they are not installed yet
	# all parameters represent a package name
	# breaks if package install failed
	function _install {
		for pkg in "${@}"; do
			dpkg-query -l $pkg > /dev/null 2> /dev/null
			if [ $? -eq 1 ]; then
				echo "Package '$pkg' needed, installing ..."
				apt-get install $pkg ||	_error Could not install $pkg
			fi
		done
	}
fi


if ! type _git_clone > /dev/null 2> /dev/null; then
	# function to clone a repository, if it doesnt exist already
	# 1 = url to repository (e.g. git://github.com/Budabot/Budabot.git)
	# 2 = repository directory (e.g. /home/budabot/nightly.repo)
	# optional 3 = branch name
	# breaks if $2 exists, but is not a repository or cloning failed, or the parameter count is invalid
	function _git_clone {
		if [ $# -eq 2 ] || [ $# -eq 3 ]; then
			if [ -e "$2" ]; then
				if [ ! -d "$2/.git" ]; then
					_error $2 does exist, but is not a git repository
				fi
			else
				if [ $# -eq 2 ]; then
					git clone "$1" "$2" || _error Could not clone git repository
				else
					git clone -b "$3" --single-branch "$1" "$2" || _error Could not clone git repository
				fi
			fi
		else
			_error Invalid _git_clone parameter count
		fi
	}
fi

if ! type _zip_install > /dev/null 2> /dev/null; then
	# function to download and extract a zip file to a specific directory
	# 1 = url to the zip file (e.g. http://www.googlecode.com/Budabot/budabot_3.0_GA_linux_12345567.zip)
	# 2 = directory to extract the zip file to (e.g. /home/budabot/stable.repo)
	# 3 = defines if the zip file contains a directory which contains the relevant files, value 0 = no inner directory, value 1 = inner diretory
	# breaks if $2 exists but is not a directory, the download and extraction process failed or the parameter count is invalid
	function _zip_install {
		if [ $# -eq 3 ]; then
			if [ -e "$2" ]; then
				if [ ! -d "$2" ]; then
					_error $2 does exist, but is not a directory
				fi
			else
				local tmpzip
				local tmpdir
				local inner
				if [ $3 -eq 0 ]; then
					tmpzip=`mktemp --dry-run` && wget -O $tmpzip "$1" && tmpdir=`mktemp -d` && unzip $tmpzip -d $tmpdir && rm $tmpzip && mv $tmpdir "$2" || _error Failed to process the zip file $1
				else
					tmpzip=`mktemp --dry-run` && wget -O $tmpzip "$1" && tmpdir=`mktemp -d` && unzip $tmpzip -d $tmpdir && rm $tmpzip && inner=`ls $tmpdir` && mv $tmpdir/$inner "$2" && rmdir $tmpdir || _error Failed to process the zip file $1
				fi
			fi
		else
			_error _Invalid zip_install parameter count
		fi
	}
fi

if ! type _mkdir > /dev/null 2> /dev/null; then
	# function to create a directory
	# 1 = directory to create (e.g. /home/budabot/nightly.repo/extras)
	# breaks when $2 exists but is not a directory, the mkdir failed or the parameter count is invalid
	function _mkdir {
		if [ $# -eq 1 ]; then
			if [ -e "$1" ]; then
				if [ ! -d "$1" ]; then
					_error $1 must be a directory
				fi
			else
				mkdir "$1" || _error Could not create directory $1
			fi
		else
			_error Invalid _mkdir parameter count
		fi
	}
fi

if ! type _cp_tpl > /dev/null 2> /dev/null; then
	# function to copy a template file and replace the place holders with correct values, if the destionation exists it will be deleted first
	# 1 = source template file (e.g. /root/budahost/scripts/config.sh)
	# 2 = destination file (e.g. /home/budabot/config.sh)
	# breaks if $1 is not a file or does not exist, $2 exists but is not a file, or the parameter count is invalid
	function _cp_tpl {
		if [ $# -eq 2 ]; then
			if [ ! -e "$1" ]; then
				_error File $1 does not exist
			else
				if [ ! -f "$1" ]; then
					_error $1 is not a file
				fi
			fi
			if [ -e "$2" ]; then
				if [ -d "$2" ]; then
					_error $1 is a directory
				else
					rm "$2"
				fi
			fi
	
			local toexport
			local var
			toexport=(HOST_USER_HOME)
			for var in "${toexport[@]}"; do
				export $var
			done
			local php_out
			php_out=`php -f "$INSTALL_DIR/replace.php" -- "$1" "$2"` || _error Template error in $1:  $php_out
		else
			_error Invalid _cp_tpl parameter count 
		fi
	}
fi

if ! type _chmod_rec > /dev/null 2> /dev/null; then
	# function to recursively set file permissions, it uses $HOST_DIR_MASK and $HOST_FILE_MASK
	# 1 = directory to apply file permissions
	# breaks if parameter count is invalid
	function _chmod_rec {
		if [ $# -eq 1 ]; then
			find "$1" -type d -print0 | xargs -0 chmod $HOST_DIR_MASK
			find "$1" -type f -print0 | xargs -0 chmod $HOST_FILE_MASK
		else
			_error Invalid _chmod_rec parameter count
		fi
	}
fi

if ! type _chmod_script > /dev/null 2> /dev/null; then
	# function to set script file permission as defined in $HOST_SCRIPT_MASK
	# all parameters represent file locations (e.g. /home/budabot/nightly.repo/chatbot.sh)
	# breaks if chmod fails
	function _chmod_script {
		for file in "${@}"; do
			chmod "$HOST_SCRIPT_MASK" "$file" || _error Could not set file permissions for $file
		done
	}
fi

if ! type _ln > /dev/null 2> /dev/null; then
	# function to create sym links
	# 1 = source path (e.g. /home/budabot/nightly.repo/chatbot.sh)
	# 2 = sym link location (e.g. /home/user/budabot/nightly.repo/chatbot.sh)
	# breaks if $1 does not exist, $2 exists but is not a symlink, $2 exists and is a symlink but does not point to $1, ln fails or invalid parameter count
	function _ln {
		if [ $# -eq 2 ]; then
			if [ ! -e "$1" ]; then
				_error Sym link source $1 does not exist
			fi
			if [ -e "$2" ]; then
				if [ -L "$2" ]; then
					local pointsto
					pointsto=`readlink "$2"`
					if [ "$1" == "$pointsto" ]; then
						return 0
					else
						_error Sym link $2 exists, but points to $pointsto, instead of $1
					fi
				else
					_error Sym link destination $2 already exists, but is not a sym link
				fi
			fi
			ln -s "$1" "$2" || _error Failed to create symlink $2 pointing to $1
		else
			_error Invalid _ln parameter count
		fi
	}
fi

if ! type _budabot_skeleton > /dev/null 2> /dev/null; then
	# function to create the budabot skeleton
	# 1 = source repository directory (e.g. /home/budabot/nightly.repo)
	# 2 = destination skeleton directory (e.g. /home/user/budabot/nightly.repo)
	# breaks if _mkdir or _ln fails, or invalid parameter count
	function _budabot_skeleton {
		if [ $# -eq 2 ]; then
			local target
			local dirs
			local symlinks
			dirs=(conf data extras logs)
			symlinks=("chatbot.sh" "core" "docs" "lib" "mainloop.php" "main.php" "modules" "conf/config.template.php" "conf/log4php.xml" "data/text.mdb")

			echo "${RTAB}Creating directories ..."
			_mkdir "$2"
			for target in "${dirs[@]}"; do
				_mkdir "$2/$target"
			done

			echo "${RTAB}Creating sym links ..."
			for target in "${symlinks[@]}"; do
				_ln "$1/$target" "$2/$target"
			done

			find "$1/extras/" -maxdepth 1 -type d | while read target; do
				target=`basename "$target"`
				if [ "$target" != "extras" ]; then
					_ln "$1/extras/$target" "$2/extras/$target"
				fi
			done || exit $?

			echo "${RTAB}Setting up proxy base"
			_mkdir "$2/proxy"
		else
			_error Invalid _budabot_skeleton parameter count
		fi
	}
fi

if ! type _acquire_lock > /dev/null 2> /dev/null; then
	# function to acquire a lock
	# 1 = name of lock, this must be a valid directory name (e.g. port)
	# breaks if it can not acquire the lock, or the parameter count is invalid
	function _acquire_lock {
		if [ $# -eq 1 ]; then
			local i
			for i in 1 2 3; do
				if mkdir "$HOST_DIR/.locks/$1" > /dev/null 2> /dev/null; then
					echo $$ > "$HOST_DIR/.locks/$1/.owner"
					break
				else
					if [ $i -eq 3 ]; then
						_error Failed to acquire lock, you may have to remove $1 manually
					else
						sleep 1
					fi
				fi
			done
		else
			_error Invalid _acquire_lock parameter count
		fi
	}
fi

if ! type _release_lock > /dev/null 2> /dev/null; then
if [ $? -ne 0 ]; then
	# function to release the acquired lock
        # 1 = name of lock, this must be a valid directory name (e.g. port)
	# breaks if lock does not exist, $1 does not seem to be a lock, the process is not the owner of the lock, releasing lock failed or invalid parameter count
        function _release_lock {
		if [ $# -eq 1 ]; then
			if [ -e "$HOST_DIR/.locks/$1" ]; then
				if [ -d "$HOST_DIR/.locks/$1" ]; then
					if [ $$ -eq `cat "$HOST_DIR/.locks/$1/.owner"` ]; then
						rm "$HOST_DIR/.locks/$1/.owner" || _error Releasing lock $1 failed
						rmdir "$HOST_DIR/.locks/$1" || _error Releasing lock $1 failed
					else
						_error Not owner of the lock
					fi
				else
					_error $1 does not seem to be a lock
				fi
			else
				_error Lock for $1 does not exist
			fi
		else
			_error Invalid _release_lock parameter count
		fi
	}
fi

if ! type _register_port > /dev/null 2> /dev/null; then
	# function to register a port, the new port will be stored in $REGISTERED_PORT
	# 1 = usage hint in form of $config_file#(api|proxy)
	# breaks if it can not acquire or release the lock, or the parameter count is invalid
	function _register_port {
		if [ $# -eq 1 ]; then
			_acquire_lock port || exit $?
			local port
			port=`grep ":$1" "$HOST_DIR/port_handler/port.list"`
			if [ $? -eq 0 ]; then
				REGISTERED_PORT=`echo "$port" | grep -oP "\\d+"`
			else
				port=`tail -1 "$HOST_DIR/port_handler/port.list" | grep -oP "\\d+"`
				if [ $? -eq 1 ]; then
					REGISTERED_PORT=`cat "$HOST_DIR/port_handler/port.base"`
				else
					REGISTERED_PORT=`expr $port + 1`
				fi
				echo "${REGISTERED_PORT}:$1" >> "$HOST_DIR/port_handler/port.list"
			fi
			_release_lock port || exit $?
		else
			_error Invalid _register_port parameter cout
		fi
	}
fi
