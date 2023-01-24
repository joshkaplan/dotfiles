# Aliases and short functions
# Josh Kaplan

# Places
alias dev='~/Dev'
alias proj='~/Projects'
alias ohmyzsh='~/.oh-my-zsh'

# Misc. Commands
alias zshconfig='vim ~/.zshrc && source ~/.zshrc'
alias zshreload='source ~/.zshrc'
# temp fix, commit this in a clean way (i.e. actually remove rmtrash)
#alias del='rmtrash'
alias rmtrash='trash'

# ls
alias l='ls -lAh'
alias la='ls -lah'
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
#alias gh="git browse"
alias gph="git push && ghcr"
alias glanph="glanp && ghcr"
alias gsu="git submodule update --init --recursive"
alias gsth="git stash"
function run-pre-commit() {
	cd "`git rev-parse --show-toplevel`"
	./.git/hooks/pre-commit
	cd -
}
alias gpc=run-pre-commit

# gla branch
glab() {
  local branch_to_update=$1
  if [[ -z $branch_to_update ]]; then
    echo "No branch given"
    return 1
  fi

  shift
  local branch_to_checkout=$*

  if [[ -z $branch_to_checkout ]]; then
    branch_to_checkout="-"
  fi

  gco "$branch_to_update"
  gla
  gco "$branch_to_checkout"
}
gslab() {
  gsth && glab "$*" && gstp
}

alias bncdeploy="gco production && git rebase main && git push && gco -"

# handy function for finding dangling commits, can then recover these with 'git stash apply'
# credit: https://stackoverflow.com/questions/89332/how-to-recover-a-dropped-stash-in-git
function git-recover-working() {
  git log --graph --oneline --decorate $(git fsck --no-reflog | awk '/dangling commit/ {print $3}')
}

# x86 aliases
alias xbrew="/usr/local/bin/brew"
alias xpython="/usr/local/bin/python3"
