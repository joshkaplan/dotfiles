# Aliases and short functions
# Josh Kaplan

# Places
alias dev='~/Dev'
alias proj='~/Projects'
alias ohmyzsh='~/.oh-my-zsh'

# Misc. Commands
alias zshconfig='vim ~/.zshrc && source ~/.zshrc'
alias del='rmtrash'
alias dj="python manage.py"
alias mp="open -a /Applications/Mailplane\ 3.app"
function ls () { /bin/ls $* | grep -v 'Icon\?\|.DS_Store' }
alias l='ls -lAh'
alias la='ls -lah'
alias reload='exec -l /usr/local/bin/zsh'
alias notif='terminal-notifier -message'
file-to-clipboard() {
    osascript \
        -e 'on run args' \
        -e 'set the clipboard to POSIX file (first item of args)' \
        -e end \
        "$@"
}
alias l1='tree -I node_modules --dirsfirst -ChFL 1'
alias l2='tree -I node_modules --dirsfirst -ChFL 2'
alias l3='tree -I node_modules --dirsfirst -ChFL 3'
alias l4='tree -I node_modules --dirsfirst -ChFL 4'
alias l5='tree -I node_modules --dirsfirst -ChFL 5'
alias l6='tree -I node_modules --dirsfirst -ChFL 6'

# Install commands
function dot() {
	CMD=$1
	shift
	eval "~/.dotfiles/bin/$CMD $*"
}

# Git Commands
alias gla="gl && git submodule update --init --recursive"
alias gl='git pull --rebase'
alias glgga='git log --graph --decorate --all --max-count=100'
alias glo='git log --oneline --decorate --color --max-count=100'
alias glog='git log --oneline --decorate --color --graph --max-count=100'
alias glb='git log --graph --oneline --decorate --no-merges --branches --max-count=100'
alias gpnp="gl && git push"
alias glanp="gla && git push"
alias gsla="git stash && gla && git stash pop"
alias gd1="git diff HEAD~1"
alias gd2="git diff HEAD~2"
alias grp="git rev-parse"
ghc() {
	git browse -- commit/$*
}
alias ghcr="ghc \`grp HEAD\`"
alias gh="git browse"
alias gph="git push && ghcr"
alias glanph="glanp && ghcr"
alias gsu="git submodule update --init --recursive"
alias gsth="git stash"
function pre-commit() {
	cd "`git rev-parse --show-toplevel`"
	./.git/hooks/pre-commit
	cd -
}
alias gpc=pre-commit

# handy function for finding dangling commits, can then recover these with 'git stash apply'
# credit: https://stackoverflow.com/questions/89332/how-to-recover-a-dropped-stash-in-git
function git-recover-working() {
  git log --graph --oneline --decorate $(git fsck --no-reflog | awk '/dangling commit/ {print $3}')
}
