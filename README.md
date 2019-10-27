# Josh Kaplan's Dotfiles

A repository for storing my configs and basic setup/installation. This is not intended to be direclty usable to anyone but myself, but most of it is fairly user agnostic.

#### Initial Setup

__One-liner:__
```bash
curl -fsSL https://github.com/joshkaplan/dotfiles/archive/master.zip > ./dotfiles.zip && unzip ./dotfiles.zip && rm ./dotfiles.zip && ./dotfiles-master/bin/install 
```

__Manual:__
1. Download folder and unzip
2. Open a terminal and cd into this package's `bin` folder
3. Run `./install`

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
* Supports per-machine configuration via `./bin/install_local` (see `./bin/install_local_example`)
* Idempotent (designed to run repeatedly without issue)

#### Links

* [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh)
* [dotbot](https://github.com/anishathalye/dotbot/)
* [atomantic/dotfiles](https://github.com/atomantic/dotfiles)
* [homebrew](https://brew.sh/)
* [pip](https://pypi.org/project/pip/)
* [Dropbox](https://db.tt/x739XBiN)
* [KarabinerElements](https://github.com/tekezo/Karabiner-Elements)
* [Hammerspoon](https://github.com/Hammerspoon/hammerspoon)
