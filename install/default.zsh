#!/usr/bin/env zsh
set -e
BASEDIR=`dirname ~/Dropbox/Dev/dotfiles/.`
PRIVATE_BASEDIR=`dirname ~/Dropbox/Dev/dotfiles-private/.`
source "${BASEDIR}/utils/utils.zsh"
source "${BASEDIR}/utils/pkg_utils.zsh"

# read options, set mode variables
zparseopts -D -E -- u=UPGRADE_MODE i=INTERACTIVE_MODE h=HELP_MODE
if [[ $HELP_MODE ]]; then 
	echo "By default, updates packaage managers and checks pacakge diffs"
	echo "\nOptions:"
	echo "    -i  interactive mode: prompt about updating package managers, and upgrading packages"
	echo "    -u  upgrade local packages"
	return 0
fi
if [[ -n $* ]]; then 
	error "Unknown options $*"
	return 1
fi

if [[ -n $UPGRADE_MODE && -n $INTERACTIVE_MODE ]]; then
	error "don't use -i and -u together"
	exit 1
fi

# check/install requirements
bot "Checking requirements"

running "\U1F37A  Checking brew"
brew_bin=$(which brew) 2>&1 > /dev/null
if [[ $? != 0 ]]; then
	action "installing brew"
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	if [[ $? != 0 ]]; then
		error "unable to install brew, script $0 abort!"
		exit 1
	fi
fi
ok

pkg_check_and_install -t brew -f "${BASEDIR}/packages/Brewfile_require" -e "\U1F37A" -a
pkg_check_and_install -t pip -f "${BASEDIR}/packages/pip_requirements.txt" -e "\U1F40D" -a

running "\U1F4DF  Checking oh-my-zsh"
if [[ ! -d ~/.oh-my-zsh ]]; then
	action "cloning oh-my-zsh"
	git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
fi
ok

running "\U1F4DF  Checking default shell"
if [ $SHELL != "/usr/local/bin/zsh" ]; then
	action "changing default shell to zsh"
	chsh -s /usr/local/bin/zsh
fi
ok

bot "Linking stuff"
# if ~/dev exists, move to ~/localdev
if [ -f ~/dev ] && [ ! -h ~/dev ]; then
	action "\U1F4C1  Moving ~/dev to ~/localdev"
	if [ -d ~/dev ]; then 
		mv ~/dev ~/localdev
		ok
	else
		error "\"~/Dev\" already exists, but it's not a directory"
		exit 1
	fi
fi
action "\U1F517  dotbot defaults"
dotbot -q -c "${BASEDIR}/install/default.conf.yaml" -d "${BASEDIR}/dotfiles"
action "\U1F517  dotbot dropbox directories"
set +e
dotbot -q -c "${BASEDIR}/install/dropbox_dir.conf.yaml" -d "${BASEDIR}/dotfiles"
set -e

# Install packages
# TODO ruby
# TODO node
bot "Syncing packages"

pkg_sync -t brew -f "${BASEDIR}/packages/Brewfile" $UPGRADE_MODE $INTERACTIVE_MODE
pkg_sync -t pip -f "${BASEDIR}/packages/pip_packages.txt" $UPGRADE_MODE $INTERACTIVE_MODE

if [[ $UPGRADE_MODE ]] || [[ $INTERACTIVE_MODE ]] && yes_no "Uppgrade oh-my-zsh?"; then 
	action "Upgrading oh-my-zsh"
	env ZSH=$ZSH sh $ZSH/tools/upgrade.sh
	ok
fi

# Search for dotfiles-private (a separate git repo), and run its default install script
if [[ -d $PRIVATE_BASEDIR ]]; then
	eval "${PRIVATE_BASEDIR}/install/default.zsh $*"
else
	warn "can't find dotfiles-local"
fi

# Search for ~/.install_local.zsh
if [[ -f ~/.install_local.zsh ]]; then
	~/.install_local.zsh $*
else
	warn "can't find ~/.install_local.zsh"
	if yes_no "Would you like create one now?"; then
		running "Copying example_install_local.zsh to ~/.install_local.zsh"
		cp "${BASEDIR}/install/example_install_local.zsh" ~/.install_local.zsh
		ok
		eval "${VISUAL} ~/.install_local.zsh"
		~/.install_local.zsh $*
	fi
fi

# Launch essential applications
bot "Launching apps"
check_and_open_app /Applications/Karabiner-Elements.app Karabiner-Elements
check_and_open_app /Applications/Slate.app Slate

echo "\n\U1F38A  Done! \U1F389"
