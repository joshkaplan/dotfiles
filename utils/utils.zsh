#!/usr/bin/env zsh

# General helpers such as prompts and echos
# Inspiration: https://github.com/atomantic/dotfiles

function yes_no() {
	echo -en "\U1F64B\U200D\U2642 "
	read -q "? $1 [y|N] " response
	response=$?
	echo
	return $response
}

function check_and_open_app() {
	running $2
	if ps -ef | grep $2 | grep -v "grep" >/dev/null; then
		ok "already running"
	else
		open $1
		ok "opened"
	fi
}

# Colorized echo helpers
autoload colors
colors
function ok() {
	ok_message=$1;
	if [[ -z $ok_message ]]; then
		ok_message="ok"
	fi
	echo -e "\U2705  ${fg_no_bold[green]}[${ok_message}]${reset_color}"
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
	(>&2 echo -e "$fg_no_bold[red][error]$reset_color "$1)
}
function cmdview() {
	echo -e "\n$fg_no_bold[yellow][$1]:$reset_color\n"$2
}
