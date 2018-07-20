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