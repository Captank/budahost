#!/bin/bash

type _error > /dev/null 2> /dev/null
if [ $? -ne 0 ]; then
	function _error {
		echo -e "${RTAB}ERROR! ${@}!\n\nFAILED!\n\n"
		BREAK=1
		exit 1
	}
fi

type _install > /dev/null 2> /dev/null
if [ $? -ne 0 ]; then
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


type _git_clone > /dev/null 2> /dev/null
if [ $? -ne 0 ]; then
	# 1 = url, 2 = directory[, 3 = branch ]
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

type _zip_install > /dev/null 2> /dev/null
if [ $? -ne 0 ]; then
	# 1 ) url, 2 = directory, 3 = 0 -> no inner directory, 1 -> inner directory
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
					tmpzip=`mktemp --dry-run` && wget -O $tmpzip "$1" && tmpdir=`mktemp -d` && unzip $tmpzip -d $tmpdir && rm $tmpzip && mv $tmpdir "$2"
				else
					tmpzip=`mktemp --dry-run` && wget -O $tmpzip "$1" && tmpdir=`mktemp -d` && unzip $tmpzip -d $tmpdir && rm $tmpzip && inner=`ls $tmpdir` && mv $tmpdir/$inner "$2" && rmdir $tmpdir
				fi
			fi
		else
			_error _Invalid zip_install parameter count
		fi
	}
fi

type _mkdir > /dev/null 2> /dev/null
if [ $? -ne 0 ]; then
	# 1 = directory
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

type _cp_tpl > /dev/null 2> /dev/null
if [ $? -ne 0 ]; then
	# 1 = source file, 2 = dest file
	function _cp_tpl {
		if [ $# -eq 2 ]; then
			if [ ! -e "$1" ]; then
				_error File $1 does not exist
			else
				if [ ! -f "$1" ]; then
					_error $1 is not a file
				fi
			fi
			echo "copy tpl $1 to $2"
			local line
			while read line; do
				line=${line//~~~HOST_USER_HOME~~~/"$HOST_USER_HOME"}
				echo "tpl: $line"
			done < "$1"
		else
			_error Invalid _cp_tpl parameter count 
		fi
	}
fi

type _chmod_rec > /dev/null 2> /dev/null
if [ $? -ne 0 ]; then
	# 1 = directory
	function _chmod_rec {
		if [ $# -eq 1 ]; then
			find "$1" -type d -print0 | xargs -0 chmod $HOST_DIR_MASK
			find "$1" -type f -print0 | xargs -0 chmod $HOST_FILE_MASK
		else
			_error Invalid _chmod_rec parameter count
		fi
	}
fi

type _chmod_script > /dev/null 2> /dev/null
if [ $? -ne 0 ]; then
	# 1, ..., n = file
	function _chmod_script {
		for file in "${@}"; do
			chmod "$HOST_SCRIPT_MASK" "$file" || _error Could not set file permissions for $file
		done
	}
fi

type _ln > /dev/null 2> /dev/null
if [ $? -ne 0 ]; then
	# 1 = sorce, 2 = dest
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
			ln -s "$1" "$2"
		else
			_error Invalid _ln parameter count
		fi
	}
fi

type _budabot_skeleton > /dev/null 2> /dev/null
if [ $? -ne 0 ]; then
	# 1 = source repo, 2 = dest repo
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

			echo "${RTAB}Setting up proxy ..."
		else
			_error Invalid _budabot_skeleton parameter count
		fi
	}
fi