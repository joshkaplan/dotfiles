#!/usr/bin/env zsh

# Utilites for managing and syncing global packages
# Author: Josh Kaplan

cd $(dirname "${0:A}")
source ./output.zsh
source ./utils.zsh

declare -A EMOJI
EMOJI[pip]="\U1F40D"
EMOJI[brew]="\U1F37A"

# Checks installed packages against a file
# Return code is 1 if their is a diff
function pkg_diff() {
	action "Checking local ${1} installs against file ${EMOJI[${1}]}"
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

	run "diff -y --suppress-common-lines <($LOCAL) $2"
}

function pkg_install() {
  local TYPE=$1
  action "Installing packages ${EMOJI[${TYPE}]}"
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
  action "Saving local ${1} packages ${EMOJI[${1}]}"
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
  action "Upgrading local ${1} packages to latest version ${EMOJI[${1}]}"
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
  action "Checking if upgrades available for local ${1} packages ${EMOJI[${1}]}"
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

# misc updates (not using a package manager)
function _update() {
  local TYPE=$1
  action "Updating ${TYPE} ${EMOJI[${TYPE}]}"
	case "$1" in
		brew)
			run "brew update"
			;;
		pip)
			run "pip3 install pip --upgrade"
			;;
	  ohmyzsh)
      # upgrade_oh_my_zsh
      run "sh ~/.oh-my-zsh/tools/upgrade.sh"
      ;;
		*)
			error "don't know how to install $1"
			return 1
	esac
}

# misc installs (not using a package manager)
function check_and_install() {
  local TYPE=$1
  local ACTION_CMD="action \"Installing ${TYPE} ${EMOJI[${TYPE}]}\""
	case "$1" in
		brew)
      if ! which brew > /dev/null; then
        eval $ACTION_CMD
        run "/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)\""
      fi
			;;
		pip)
		  if ! which pip3 > /dev/null; then
        error "pip should be installed with brew"
        return 1
		  fi
			;;
	  ohmyzsh)
      if [[ ! -d ~/.oh-my-zsh ]]; then
        eval $ACTION_CMD
        run "git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh"
      fi
      ;;
		*)
			error "don't know how to install $1"
			return 1
	esac
}

function pkg_check_diff_and_do() {
  local FAST_MODE=$3;
  if [[ $FAST_MODE ]]; then
    eval $1
  else
    if ! pkg_diff $PKG_TYPE $FILE; then
      if [[ $? -gt 1 ]]; then
        error "Problem with diff"
        exit 1
      fi
      if yes_no $2; then
        eval $1
      fi
    fi
  fi
}
