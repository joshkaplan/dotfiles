# Josh Kaplan's Dotfiles

A repository for storing my configs and basic setup/installation. This is not intended to be direclty usable to anyone but myself, but most of it is be fairly user agnostic.

#### Initial Setup

0. (optional) Install iTerm2. 
1. Install Dropbox, sync selectively. 
2. Navigate to this folder in a terminal (preferably iTerm2) and install:
```bash
cd ~/Dropbox/dev/dotfiles
./install/default.zsh
```
3. Finish the software setup:
	1. Install/launch KarabinerElements.
	2. Install/launch Slate.
	3. Install/launch iTerm2. Set settings file.
	4. Install/launch Alfred. Set settings file.

#### Sync

Evrery time you want to sync, you can simply re-run install.zsh from this folder.

```bash
cd ~/.dotfiles
./install/default.zsh
```

#### Features

* Symlinks stuff (using `dotbot`):
	* dotfiles
	* certain Dropbox folders into `~/` 
	* some application settings
* Installs, syncs, and upgrades `brew` and `pip` packages
* Supports private configuration via `dotfiles-private`, a private repo built with a similar structure to this one
* Supports per-machine configuration via `~/.install_local.zsh` (see `install/example_install_local.zsh`)
* Can be run unlimited times without issue (`install/` are all idempotent)

#### Links

* [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh)
* [dotbot](https://github.com/anishathalye/dotbot/)
* [homebrew](https://brew.sh/)
* [pip](https://pypi.org/project/pip/)
* [iTerm2](https://www.iterm2.com/) (and [colors](https://github.com/mbadolato/iTerm2-Color-Schemes))
* [Dropbox](https://db.tt/x739XBiN)
* [atomantic/dotfiles](https://github.com/atomantic/dotfiles)
* [Alfred](https://www.alfredapp.com/)
* [KarabinerElements](https://github.com/tekezo/Karabiner-Elements)
* [slate](https://github.com/mattr-/slate) (no longer maintained, but still works; I'll switch to [Hammerspoon](https://github.com/Hammerspoon/hammerspoon) or [Phoenix](https://github.com/kasper/phoenix) at some point)