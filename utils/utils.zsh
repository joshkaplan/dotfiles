#!/usr/bin/env zsh

cd $(dirname "${0:A}")
source ./output.zsh

function yes_no() {
	echo -en "\U1F64B\U200D\U2642 "
	read -q "? $1 [y|N] " response
	response=$?
	echo
	return $response
}

function prompt() {
	echo -en "\U1F64B\U200D\U2642 $1 "
	read $2
}

function check_and_open_app() {
	action "Checking if $1 is running"
	if ! run "ps -ef | grep $2 | grep -v grep"; then
		run "open $3"
	fi
}
