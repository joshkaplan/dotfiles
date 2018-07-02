#!/usr/bin/env zsh
set -e
BASEDIR=`dirname ~/Dropbox/Dev/dotfiles/.`
PRIVATE_BASEDIR=`dirname ~/Dropbox/Dev/dotfiles-private/.`
source "${BASEDIR}/install/utils.sh"

# check/install requirements
bot "Checking requirements"

running "brew"
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

# TODO require dotbot (specific version probably)

require_brew python2
require_brew git
require_brew zsh
running "oh-my-zsh"
if [ ! -d ~/.oh-my-zsh ]; then
	action "cloning oh-my-zsh"
	git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
fi
ok

running "checking default shell"
if [ $SHELL != "/usr/local/bin/zsh" ]; then
	action "changing default shell to zsh"
	chsh -s /usr/local/bin/zsh
fi
ok

bot "Linking stuff"
# if ~/dev exists, move to ~/localdev
if [ -f ~/dev ] && [ ! -h ~/dev ]; then
	running "Moving ~/dev to ~/localdev"
	if [ -d ~/dev ]; then 
		mv ~/dev ~/localdev
		ok
	else
		error "\"~/Dev\" already exists, but it's not a directory"
		exit 1
	fi
fi
dotbot -c "${BASEDIR}/install/default.conf.yaml" -d "${BASEDIR}/dotfiles"

# TODO sync apps
# Alfred plutil -p com.runningwithcrayons.Alfred-Preferences-3.plist
# iTerm
# 

# Install packages
# TODO ruby
# TODO node
bot "Syncing packages"
if yes_no "Sync packages?"; then
	if yes_no "Update package managers (recommended)?"; then
		running "Updating brew"
		echo
		brew update
		ok "Brew is up to date"
		running "Updating pip"
		echo
		pip install pip --upgrade
		ok "Pip is up to date"
	fi

	# Brew
	DIFF_CMD="diff -y --suppress-common-lines <(brew bundle dump --file=-) \"${BASEDIR}/packages/Brewfile\""
	INSTALL_CMD="brew bundle --file=\"${BASEDIR}/packages/Brewfile\" --no-upgrade"
	SAVE_CMD="brew bundle dump --force --file=\"${BASEDIR}/packages/Brewfile\""
	UPGRADE_CMD="brew upgrade"
	pkg_sync Homebrew Brewfile $DIFF_CMD $INSTALL_CMD $SAVE_CMD $UPGRADE_CMD

	# Pyton
	DIFF_CMD="diff -y <(pip freeze) \"${BASEDIR}/packages/python_requirements.txt\""
	INSTALL_CMD="pip install -r \"${BASEDIR}/packages/python_requirements.txt\""
	SAVE_CMD="pip freeze > \"${BASEDIR}/packages/python_requirements.txt\""
	UPGRADE_CMD="pip install -U"
	pkg_sync Python requirements.txt $DIFF_CMD $INSTALL_CMD $SAVE_CMD $UPGRADE_CMD 
	
	if yes_no "Uppgrade oh-my-zsh?"; then 
		action "Upgrading oh-my-zsh"
		env ZSH=$ZSH sh $ZSH/tools/upgrade.sh
		ok "oh-my-zsh upgraded"
	fi
fi

# Search for dotfiles-private (a separate git repo), and run its default install script
if [ -d $PRIVATE_BASEDIR ]; then
	eval "${PRIVATE_BASEDIR}/install/default.sh"
else
	warn "can't find dotfiles-local"
fi

# Search for ~/.install_local.sh
if [ -f ~/.install_local.sh ]; then
	~/.install_local.sh
else
	warn "can't find ~/.install_local.sh"
	if yes_no "Would you like create one now?"; then
		running "Copying example_install_local.sh to ~/.install_local.sh"
		cp "${BASEDIR}/install/example_install_local.sh" ~/.install_local.sh
		ok
		eval "${VISUAL} ~/.install_local.sh"
	fi
fi

bot "DONE"
