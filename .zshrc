# ------------------------------- SETTINGS ----------------------------------- #
# stop ctrl-q/s from 'bork'ing terminal
stty -ixon

# zsh history
export HISTSIZE=1000000
export SAVEHIST=200000000
export HISTFILE=~/.zsh_history
setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_IGNORE_DUPS          # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete an old recorded event if a new event is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a previously found event.
setopt HIST_IGNORE_SPACE         # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file.
setopt HIST_VERIFY               # Do not execute immediately upon history expansion.

# golang
export GOPATH=$HOME/git
export GO111MODULE=on
export GOPRIVATE=*github.com/github/*
export PATH=$PATH:$GOPATH/bin:$GOROOT/bin:$HOME/bin:$HOME/.scripts

# ruby
export PATH="/usr/local/opt/ruby/bin:$PATH"
# dotcom
#export PATH="/Users/chriskirkland/git/src/github.com/github/github/bin:$PATH"

# cron
#export EDITOR=vim

# ansible
export ANSIBLE_NOCOWS=1

# ------------------------------ TERMINAL SETTINGS --------------------------- #
# terminal coloring
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# Based on http://www.terminally-incoherent.com/blog/2013/01/14/whats-in-your-bash-prompt/
# Colors
Color_Off=$'\033[0m'
Red=$'\033[0;31m'
Green=$'\033[0;32m'
Purple=$'\033[0;35m'
LightBlue=$'\e[94m'
Dim=$'\e[2m'
# local config
uname="cmkirkla"
hname="mymbp"

# setup command prompt
function precmd() {
  # capture the exit status of the last command
  local EXIT="$?"

  PROMPT='> '
  local _PROMPT=""

  # previous command exit code indicator
  if [ $EXIT -eq 0 ]; then _PROMPT+="${Green}✔${Color_Off} "; else _PROMPT+="${Red}✘${Color_Off} "; fi

  # TODO(cmkirkla): add kubernetes context? Helm symbol --> ⎈
  local kubernetes_context=$(kubectl config current-context 2>&1)
  if [[ "$kubernetes_context" =~ "error: current-context is not set" ]]; then
    _PROMPT+="${Dim}⎈ (∅)${Color_Off} "
  else
    _PROMPT+="${LightBlue}⎈ (${kubernetes_context})${Color_Off} "
  fi

  # check if inside git repo
  local git_status="$(git status -unormal 2>&1)"
  if ! [[ "$git_status" =~ "Not a git repo" ]]; then
    # parse the porcelain output of git status
    if [[ "$git_status" =~ "nothing to commit" ]]; then
      local Color_On=$Green
    elif [[ "$git_status" =~ "nothing added to commit but untracked files present" ]]; then
      local Color_On=$Purple
    else
      local Color_On=$Red
    fi
    local remote=$(git config --get remote.origin.url)
    if echo $remote | grep -q https; then
      local repo=$(git config --get remote.origin.url | cut -d'/' -f5 | cut -d'.' -f1)
    else
      local repo=$(git config --get remote.origin.url | cut -d'/' -f2 | cut -d'.' -f1)
    fi

    if [[ "$git_status" =~ "On branch "([^[:space:]]+) ]]; then
      local branch=${match[1]}
    else
      # Detached HEAD. (branch=HEAD is a faster alternative.)
      local branch="($(git describe --all --contains --abbrev=4 HEAD 2> /dev/null || echo HEAD))"
    fi
    # add the result to prompt
    _PROMPT+="${repo}:(${Color_On}${branch}${Color_Off}) "
  else
    # basic information (user@host:path)
    _PROMPT+="${BRed}${uname}${Color_Off}@${BRed}${hname}${Color_Off}:${BPurple}$(dirs -0)${Color_Off} "
  fi

  echo -e "$_PROMPT"
}

# -------------------------- UTILITY FUNCTIONS ------------------------------ #
# auto-expand relative paths for `ln`
#function ln()
#{
#  # argument parsing strategy taking adapted from
#  #   http://unix.stackexchange.com/a/156231
#
#  # parse flags
#  parsed_options=$(getopt -o Ffhinsv -- "$@")
#	eval "set -- $parsed_options"
#  FLAGS=""
#	while [ "$#" -gt 0 ]; do
#    case $1 in
#      (-[Ffhinsv]) FLAGS="$FLAGS $1"; shift;;
#      (--) shift; break;;
#      (*) exit 1 # should never be reached.
#    esac
#  done
#
#  # parse non-flag arguments and expand paths
#  PATHS=""
#  while [ "$#" -gt 0 ]; do
#    PATHS="$PATHS $(readlink -f $1)"
#    shift
#  done
#
#  # run command
#  eval "ln \"$FLAGS\" \"$PATHS\""
#}

function bookends()
{
  head -n1 $1
  tail -n1 $1
}

function gerr()
{
  cd results/
  logfile=$(ls -1 | grep "results-[0-9]\{10\}.log$" | tail -n 1)
  tail -f -n 2000000 $logfile | grep ERROR
}

function glog()
{
  # Example usage:
  #   glog "(ERROR|FAILED|Action|error|Error|ConnectionPool)"
  logfile=$(ls -1 results/*.log| grep "results-[0-9]\{10\}.log$" | tail -n 1)
  echo -e "Searching through \"$logfile\"...\n"
  tail -f -n 2000000 $logfile | grep -P $1
}

# ensure "old"-style docker daemon is running and connected
function dstart()
{
  # check if docker daemon is running
  if docker-machine status | grep -q "Stopped"
  then
    echo "starting docker daemon..."
    # DOCKER_OPTS="--bip 10.255.0.1/16" docker-machine start
    docker-machine start
  fi

  # check if docker daemon is active
  if ! [ -z ${DOCKER_MACHINE_NAME+x} ] || docker-machine active 2>&1 | grep -q "No active host found"
  then
    echo "connecting to docker daemon..."
    eval $(docker-machine env)
  fi
}

# enable git tab completion (zsh has built-in git completion)
autoload -Uz compinit && compinit -u

# Git TimeWarp (moves git commits forward $1 hours)
# It would be really great to get this working....
# function gtw()
# {
#   HOURS=$1
#   if ! [[ $HOURS =~ ^[0-9]+$ ]]  # not an integer
#   then
#     echo "Expected integer but found \"$HOURS\". Exiting..."
#     return 1
#   fi
#
#   for COMMIT_HASH in $(git show origin/master..HEAD -q | grep -P "^commit" | grep -Po "[a-f0-9]{40}")
#   do
#     echo $COMMIT_HASH $HOURS
#   done
# }

# setup web development workflow for pug/sass
function wdlaunch()
{
  # set defaults
  PUG_FROM_DIR="pug"
  PUG_TO_DIR="."
  SASS_FROM_DIR="sass"
  SASS_TO_DIR="css"

  # pull from conf if it exists
  CONF="$(pwd)/.wdlaunch.conf"
  if [ -f "$CONF" ]; then
    source $CONF
  fi

  # resolve paths
  PUG_FROM_DIR=$(readlink -f $PUG_FROM_DIR)
  PUG_TO_DIR=$(readlink -f $PUG_TO_DIR)
  SASS_FROM_DIR=$(readlink -f  $SASS_FROM_DIR)
  SASS_TO_DIR=$(readlink -f $SASS_TO_DIR)

  # render pug --> html
  pug -P ${PUG_FROM_DIR} --out ${PUG_TO_DIR}
  pug --watch -P ${PUG_FROM_DIR} --out ${PUG_TO_DIR} &

  # render sass --> css
  SASS_ARGS="--quiet --sourcemap=none --style=expanded"
  # sass $SASS_ARGS ${SASS_FROM_DIR}:${SASS_TO_DIR}
  sass --watch $SASS_ARGS ${SASS_FROM_DIR}:${SASS_TO_DIR} &

  # wait on child processes
  wait
}

# 'git update branch' - update current branch at "highest" relevant branch:
#   {local upstream} > "upstream" > "origin" > "cmkirkla" > {first defined remote}
function gub() {
  git_status="$(git status -unormal 2>&1)"
  if [[ "$git_status" =~ "On branch "([^[:space:]]+) ]]; then
    branch=${match[1]}
  else
    # exit
    >&2 echo "Either in detached head state or not in a git repo"
  fi

  # get local upstream if it exists
  upstream=$(git config --local --get branch.${branch}.remote)
  if [ -z ${upstream} ]; then
    # grab the "highest" ranked remote
    remotes=$(git remote)
    if [[ $remotes = *"upstream"* ]]; then
      upstream="upstream"
    elif [[ $remotes = *"origin"* ]]; then
      upstream="origin"
    elif [[ $remotes = *"cmkirkla"* ]]; then
      upstream="cmkirkla"
    else
      upstream=$(git remote | head -n1)
    fi
  fi


  BLUE="\033[1;34m" # Light Blue
  NC='\033[0m' # No Color
  PRE='›››'
  pretty_print "git fetch ${upstream} && git merge --ff-only ${upstream}/${branch}"
  git fetch ${upstream} && git merge --ff-only ${upstream}/${branch}
}

# prints the underlying command for an alias
function print_alias() {
  #TODO(cmkirkla): include trailing command line args
  pretty_print "$(alias $@ | cut -d"'" -f2 | cut -d";" -f2- | cut -d'&' -f3-| xargs)"
}

function pretty_print() {
  BLUE="\033[1;34m" # Light Blue
  NC='\033[0m' # No Color
  PRE='›››' # Magic carrots
  printf "${PRE} Running ${BLUE}$@${NC}\n"
}

### source aliases to decorate
# In zsh, aliases are always expanded, so we don't need 'shopt -s expand_aliases'
if [ -f ~/.zsh_aliases_decorated ]; then
  source ~/.zsh_aliases_decorated
fi

### Decorate all aliases to print the underlying command (educational purposes)
# Note: This functionality doesn't work properly (as noted in the original bashrc - "THIS LINE DOESN'T WORK!!!")
# Commenting out to preserve alias functionality
# The while loop syntax needs to be adapted for zsh
# for ALIAS in "${(@f)$(alias | cut -d' ' -f2-)}"; do
#   ALIAS_NAME=$(echo $ALIAS | cut -d'=' -f1)
#   ALIAS_VAL=$(echo $ALIAS | cut -d'=' -f2- | cut -d"'" -f2)
#   cmd="alias ${ALIAS_NAME}='print_alias ${ALIAS_NAME} && ${ALIAS_VAL}'"
#   eval "$cmd" # THIS LINE DOESN'T WORK!!!
# done

# source core aliases (not to be decorated); e.g. ggrep-->grep
if [ -f ~/.zsh_aliases_core ]; then
  source ~/.zsh_aliases_core
fi

# ------------------------- INCLUDE OTHER STUFF ----------------------------- #
# source other private and/or machine specific configurations
PLUGIN_DIR=~/.zsh
if [ -d "$PLUGIN_DIR" ]; then
  for f in $PLUGIN_DIR/*; do
    source $f
  done
fi

### Added by the Bluemix CLI
#source /usr/local/Bluemix/bx/bash_autocomplete

# thefuck alias (if installed)
if command -v thefuck &> /dev/null; then
  eval $(thefuck --alias fk)
  eval $(thefuck --alias)
fi

### github helpers

function gcr_inner() {
  local ORG_AND_REPO=$1
  local PREVIOUS_DIR=$(pwd)

  local GITHUB_HOME="$HOME/git/src/github.com"
  cd $GITHUB_HOME

  # default to 'github' org is no prefix provided
  if [[ "$ORG_AND_REPO" != *"/"* ]]; then
    echo "defaulting to 'github' org"
    ORG_AND_REPO="github/$ORG_AND_REPO"
  fi

  # early return if repo already exists
  if [ -d "$ORG_AND_REPO" ];
  then
    echo "repo already exists..."
    echo "entering $GITHUB_HOME/$ORG_AND_REPO/"
    cd $GITHUB_HOME/$ORG_AND_REPO/
    return 0
  fi

  # In zsh, we use different syntax for string splitting
  local partsArr=("${(@s:/:)ORG_AND_REPO}")
  local ORG=${partsArr[1]}
  local REPO=${partsArr[2]}

  # ensure ORG is setup and enter
  if [ ! -d "$ORG" ];
  then
    echo "org $ORG is missing. setting up..."
    mkdir $ORG
  fi
  echo "entering $GITHUB_HOME/$ORG/"
  cd $GITHUB_HOME/$ORG/

  # clone REPO and enter
  git clone --depth 1 git@github.com:$ORG_AND_REPO.git
  echo "entering $GITHUB_HOME/$ORG/$REPO/"
  cd $GITHUB_HOME/$ORG/$REPO/
  return 0
}

function gcr() {
  # if the new repo checkout fails, put us back into our previous pwd
  if ! gcr_inner $1; then
    echo "repo clone failed. backing out..."
    cd $PREVIOUS_DIR
  fi
}

function orb() {
  # open repo in browser
  local ORG_AND_REPO=$(git rev-parse --show-toplevel | rev | cut -d '/' -f1-2 | rev)
  open "https://github.com/$ORG_AND_REPO"
}

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
