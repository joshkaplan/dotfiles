#!/usr/bin/env zsh

# Utilites for managing and syncing global packages
# Author: Josh Kaplan

# check if file is installed
function pkg_check_file() {
	_pkg_check $*
}

# check if local stuff is in the file
function pkg_check_local() {
	_pkg_check -l $*
}

# show the diff
function pkg_check_diff() {
	_pkg_check -d $*
}
# Checks installed packages against a file
# Return code is 1 if their is a diff
function _pkg_check() {
	zparseopts -D -E -- l=LOCAL_MODE d=DIFF_MODE
	case "$1" in
		brew)
			local LOCAL="brew bundle dump --file=-"
			;;
		pip)
			local LOCAL="pip3 freeze"
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
	local CMD="diff $OPTIONS <($LOCAL) $2"
	local DIFF=$(eval $CMD)
	CODE=$?
	set -e
	fake_run $CMD $DIFF

	if [[ $CODE -gt 1 ]]; then
		error "problem with diff"
		return $CODE
	elif [[ -z $DIFF ]]; then
		return 0
	fi
	return 1
}

function pkg_install() {
	case "$1" in
		brew)
			run "brew bundle -v --file=$2 --no-upgrade"
			;;
		pip)
			run "pip3 install -r $2"
			;;
		*)
			error "unknown package manager $1"
			return 1
	esac
}

function pkg_save() {
	case "$1" in
		brew)
			run "brew bundle dump --force --file=$2"
			;;
		pip)
			run "pip3 freeze > $2"
			;;
		*)
			error "unknown package manager $1"
			return 1
	esac
}

function pkg_upgrade() {
	case "$1" in
		brew)
			run "brew upgrade"
			;;
		pip)
			# run "pip3 install -U"
			warn "pip does not support a bulk upgrade; you will need to run 'pip install -U' for each package"
			;;
		*)
			error "unknown package manager $1"
			return 1
	esac
}

function pkg_outdated() {
	case "$1" in
		brew)
			run "brew outdated -v"
			;;
		pip)
			run "pip3 list -o"
			;;
		*)
			error "unknown package manager $1"
			return 1
	esac
}

function pkg_update() {
	case "$1" in
		brew)
			run "brew update"
			;;
		pip)
			run "pip3 install pip --upgrade"
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
	action "Checking if ${PKG_TYPE} packages are installed ${EMOJI}"
	if ! pkg_check_file $PKG_TYPE $FILE; then
		if [[ -n $AUTO_INSTALL ]] || yes_no "Would you like to install these ${PKG_TYPE} packages?"; then
			action "Installing packages ${EMOJI}"
			pkg_install $PKG_TYPE $FILE
		fi
	fi
}
