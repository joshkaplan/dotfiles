# Josh Kaplan's Dotfiles

A repository for storing my configs and basic setup/installation. This is not intended to be direclty usable to anyone but myself, but most of it is fairly user agnostic.

#### Initial Setup

1. Install [Dropbox](https://db.tt/x739XBiN), sync selectively. 
2. Run install:
```bash
~/Dropbox/dev/dotfiles/bin/install
```

#### Sync

Evrery time you want to sync, you can simply re-run `install`, which is aliased to:
```bash
 dot install
```

#### Features

* Symlinks stuff using `dotbot`:
	* dotfiles
	* Dropbox folders
	* application settings
* Installs, syncs, and upgrades `brew` and `pip` packages
* Supports private configuration via `dotfiles-private`, a private repo built with a similar structure to this one
* Supports per-machine configuration via `~/.install_local.zsh` (see `install/example_install_local.zsh`)
* Idempotent (designed to run repeatedly without issue)

#### Links

* [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh)
* [dotbot](https://github.com/anishathalye/dotbot/)
* [atomantic/dotfiles](https://github.com/atomantic/dotfiles)
* [homebrew](https://brew.sh/)
* [pip](https://pypi.org/project/pip/)
* [iTerm2](https://www.iterm2.com/) (and [colors](https://github.com/mbadolato/iTerm2-Color-Schemes))
* [Dropbox](https://db.tt/x739XBiN)
* [Alfred](https://www.alfredapp.com/)
* [KarabinerElements](https://github.com/tekezo/Karabiner-Elements)
* [slate](https://github.com/mattr-/slate) (no longer maintained, but still works; I'll switch to [Hammerspoon](https://github.com/Hammerspoon/hammerspoon) or [Phoenix](https://github.com/kasper/phoenix) at some point)
