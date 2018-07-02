#!/usr/bin/env zsh

# Utils such as prompts and echos
# Inspiration: https://github.com/atomantic/dotfiles

function yes_no() {
	echo -en "\U1F64B\U200D\U2642 "
	read -q "? $1 [y|N] " response
	response=$?
	echo
	return $response
}

# Colorized echo helpers
autoload colors
colors
function ok() {
	echo -e "$fg_no_bold[green][ok]$reset_color "$1
}
function bot() {
	echo -e "\n\U1F916 " $1
}
function running() {
	echo -en "$fg_no_bold[magenta] ⇒ $reset_color"$1": "
}
function action() {
	echo -e "$fg_no_bold[magenta][action]:$reset_color\n ⇒ $1..."
}
function warn() {
	echo -e "$fg_no_bold[yellow][warning]$reset_color "$1
}
function error() {
	echo -e "$fg_no_bold[red][error]$reset_color "$1
}
function diffview() {
	echo -e "\n$fg_no_bold[yellow][diff]:$reset_color\n"$1
}

# Check requirements
function require_brew() {
	running $1
	if ! brew ls $1 > /dev/null 2>&1; then
		action "brew install $1"
		brew install $1
	fi
	ok
}

# Sync packages
function pkg_sync() {
	PKG_TYPE=$1; PKG_SOURCE=$2;
	DIFF_CMD=$3; INSTALL_CMD=$4; SAVE_CMD=$5; UPGADE_CMD=$6
	if yes_no "Upgrade ${PKG_TYPE} packages?"; then 
		action "Upgrading"
		eval $UPGADE_CMD
		ok "${PKG_SOURCE} packages upgraded to latest version"
	fi
	running "Checking ${PKG_TYPE} packages"
	set +e
	DIFF=`eval $DIFF_CMD`
	DIFF_CODE=$?
	set -e
	if [ $DIFF_CODE -gt 1  ]; then
		error "Problem with diff"
		exit 1
	elif [ $DIFF_CODE -eq 1  ]; then
		diffview "$DIFF"
		if yes_no "Install missing ${PKG_TYPE} packages from ${PKG_SOURCE} (right side)?"; then
			action "Installing"
			eval $INSTALL_CMD
			ok "${PKG_TYPE} packages installed from ${PKG_SOURCE}"
		fi
		if yes_no "Save ${PKG_TYPE} packages to ${PKG_SOURCE}?"; then 
			action "Saving"
			eval $SAVE_CMD
			ok "${PKG_TYPE} packages saved to ${PKG_SOURCE}"
		fi
	else
		ok "Already in sync"
	fi
}
