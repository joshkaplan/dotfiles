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
	action "Checking if $2 is running"
	if ! run "ps -ef | grep $2 | grep -v grep"; then
		run "open $1"
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

function warn() {
	echo -e "$fg_no_bold[yellow][warning]$reset_color "$1
}

function error() {
	(>&2 echo -e "$fg_no_bold[red][error]$reset_color "$1)
}

# source: https://wiki.bash-hackers.org/snipplets/print_horizontal_line#a_line_across_the_entire_width_of_the_terminal
function divider() {
  echo -n "$fg_bold[$1]"
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' "-"
  echo -n "$reset_color"
}

function section() {
  echo
  echo -e "$fg_bold[cyan]\U1F916 Begin $1$reset_color"
}

function end_section() {
  echo
  echo -e "$fg_bold[cyan]\U1F916 Done $1$reset_color"
}

function action() {
  echo
  echo -e "\U1F916 $1...$reset_color"
#  eval $*
}

function run() {
  divider
  echo -e "> $fg_bold[magenta]$*$reset_color"
  eval $*
  local return=$?
  divider
  return $return
}

function fake_run() {
  divider
  echo -e "> $fg_bold[magenta]$1$reset_color"
  echo $2
  divider
}
