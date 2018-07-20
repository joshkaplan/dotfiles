#!/usr/bin/env zsh

# Utilites for managing and syncing global packages
# Author: Josh Kaplan

function pkg_check_file() {
	_pkg_check $*
}
function pkg_check_local() {
	_pkg_check -l $*
}
function pkg_check_diff() {
	_pkg_check -d $*
}
# Checks installed packages against a file
# Outputs missing packages if there are any; otherwise blank
# Return code is always 0 except on error
function _pkg_check() {
	zparseopts -D -E -- l=LOCAL_MODE d=DIFF_MODE
	case "$1" in
		brew)
			LOCAL=`brew bundle dump --file=-`
			;;
		pip)
			LOCAL=`pip freeze`
			;;
		*)
			error "unknown package manager $1"
			return 1
	esac

	if [[ -n $DIFF_MODE ]]; then
		OPTIONS="-y --suppress-common-lines"
	elif [[ -n $LOCAL_MODE ]]; then
		OPTIONS="--new-line-format='' --unchanged-line-format=''"
	else
		OPTIONS="--old-line-format='' --unchanged-line-format=''"
	fi
	set +e
	DIFF=`eval diff $OPTIONS <(echo $LOCAL) $2`
	CODE=$?
	set -e
	if [[ $CODE -gt 1 ]]; then
		error "problem with diff"
		return $CODE
	elif [[ -z $DIFF ]]; then
		return 0
	fi
	echo $DIFF
	return 0
}

function pkg_install() {
	case "$1" in
		brew)
			brew bundle --file=$2 --no-upgrade
			;;
		pip)
			pip install -r $2
			;;
		*)
			error "unknown package manager $1"
			return 1
	esac
}

function pkg_save() {
	case "$1" in
		brew)
			brew bundle dump --force --file=$2
			;;
		pip)
			pip freeze > $2
			;;
		*)
			error "unknown package manager $1"
			return 1
	esac
}

function pkg_upgrade() {
	case "$1" in
		brew)
			brew upgrade
			;;
		pip)
			pip install -U
			;;
		*)
			error "unknown package manager $1"
			return 1
	esac
}

function pkg_outdated() {
	case "$1" in
		brew)
			brew outdated -v
			;;
		pip)
			pip list -o
			;;
		*)
			error "unknown package manager $1"
			return 1
	esac
}

function pkg_update() {
	case "$1" in
		brew)
			brew update > /dev/null
			;;
		pip)
			pip install pip --upgrade > /dev/null
			;;
		*)
			error "unknown package manager $1"
			return 1
	esac
}

function pkg_check_and_install() {
	zparseopts -D -E -- t:=PKG_TYPE f:=FILE e:=EMOJI a=AUTO_INSTALL
	PKG_TYPE=$PKG_TYPE[2]
	FILE=$FILE[2]
	EMOJI=$EMOJI[2]
	FILENAME="${FILE##*/}" 
	running "${EMOJI}  Checking ${PKG_TYPE} packages"
	CHECK=`pkg_check_file $PKG_TYPE $FILE`
	if [[ -z $CHECK ]] ; then
		ok
	else
		cmdview "not installed" $CHECK
		if [[ -n $AUTO_INSTALL ]] || yes_no "Would you like to install these ${PKG_TYPE} packages?"; then
			action "Installing"
			pkg_install $PKG_TYPE $FILE
			ok 	"${PKG_TYPE} packages installed from ${FILENAME}"
		fi
	fi
}

function pkg_sync() {
	set -e
	source "${BASEDIR}/utils/utils.zsh"

	# Process and validate args
	zparseopts -D -E -- t:=PKG_TYPE f:=FILE u=UPGRADE_MODE i=INTERACTIVE_MODE h=HELP_MODE
	if [[ $HELP_MODE ]]; then 
		echo "By default, updates packaage managers and checks pacakge diffs"
		echo "\nUsage:"
		echo "    pkg_sync -f file -t type [-i|-u]"
		echo "\nOptions:"
		echo "    -i  interactive mode"
		echo "    -u  upgrade local packages"
		return 0
	fi
	if [[ -n $* ]]; then 
		error "Unknown options $*"
		return 1
	fi
	PKG_TYPE=$PKG_TYPE[2]
	FILE=$FILE[2]
	FILENAME="${FILE##*/}"
	case "$PKG_TYPE" in
		brew)
			EMOJI="\U1F37A"
			;;
		pip)
			EMOJI="\U1F40D"
			;;
		*)
			error "unknown package manager $PKG_TYPE"
			return 1
	esac
	if [[ ! -f $FILE ]]; then
		error "Invalid file '${FILE}'"
		return 1
	fi

	# Update package manager (yes bey default)
	if [[ -z $INTERACTIVE_MODE ]] || yes_no "Would you like to update ${PKG_TYPE} (recommended)?"; then 
		running "${EMOJI}  Updating ${PKG_TYPE}"
		pkg_update $PKG_TYPE
		ok
	fi

	# Check outdated / upgrade
	if [[ -n $INTERACTIVE_MODE ]]; then
		running "${EMOJI}  Checking outdated ${PKG_TYPE} packages"
		OUTDATED=`pkg_outdated $PKG_TYPE`
		cmdview outdated $OUTDATED
	fi
	if [[ -n $UPGRADE_MODE ]] || [[ -n $INTERACTIVE_MODE ]] && yes_no "Would you like to upgrade these ${PKG_TYPE} packages?"; then 
		action "Upgrading"
		pkg_upgrade $PKG_TYPE
		ok "${PKG_TYPE} packages upgraded to latest version"
	fi

	# Check if packages from file are installed
	pkg_check_and_install -t $PKG_TYPE -f $FILE -e $EMOJI

	# Check diff between local and file (INTERACTIVE MODE)
	if [[ -n $INTERACTIVE_MODE ]]; then 
		running "${EMOJI}  Checking if local packages are in sync with ${FILENAME}"
		CHECK=`pkg_check_diff $PKG_TYPE $FILE`
		if [[ -z  $CHECK ]] ; then
			ok
		else
			cmdview "diff" $CHECK
			if yes_no "Save local packages (left) to ${FILENAME} (right)?"; then
				action "Saving"
				pkg_save $PKG_TYPE $FILE
				ok 	"${PKG_TYPE} packages saved to ${FILE}"
			fi
		fi
	fi
}