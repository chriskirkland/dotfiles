# ------------------------------- SETTINGS ----------------------------------- #
# stop ctrl-q/s from 'bork'ing terminal
stty -ixon

# bash history
HISTSIZE=10000
HISTFILESIZE=20000

# golang
export GOPATH=$HOME/git
export GOROOT=/usr/local/Cellar/go/1.8.5/libexec  # remove this for go>=1.9
export PATH=$PATH:$GOPATH/bin:$GOROOT/bin

# cron
export EDITOR=vim

# ansible
export ANSIBLE_NOCOWS=1

# ------------------------------ TERMINAL SETTINGS --------------------------- #
# terminal coloring
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
# default prompt style
export PS1="[\@] \u> "

# Based on http://www.terminally-incoherent.com/blog/2013/01/14/whats-in-your-bash-prompt/
# Colors
Color_Off='\033[0m'
Red='\033[0;31m'
Green='\033[0;32m'
Purple='\033[0;35m'
LightBlue='\e[94m'
Dim='\e[2m'
# local config
uname="cmkirkla"
hname="mymbp"
# setup command prompt
function __prompt_command()
{
  # capture the exit status of the last command
  EXIT="$?"

  PS1='> '
  _PROMPT=""

  # previous command exit code indicator
  if [ $EXIT -eq 0 ]; then _PROMPT+="${Green}\u2714${Color_Off} "; else _PROMPT+="${Red}\u2718${Color_Off} "; fi

  # TODO(cmkirkla): add kubernetes context? Helm symbol --> \u2388
  local kubernetes_context=$(kubectl config current-context 2>&1)
  if [[ "$kubernetes_context" =~ "error: current-context is not set" ]]; then
    _PROMPT+="${Dim}\u2388 (\u2205)${Color_Off} "
  else
    _PROMPT+="${LightBlue}\u2388 (${kubernetes_context})${Color_Off} "
  fi

  # check if inside git repo
  local git_status="`git status -unormal 2>&1`"
  if ! [[ "$git_status" =~ Not\ a\ git\ repo ]]; then
    # parse the porcelain output of git status
    if [[ "$git_status" =~ nothing\ to\ commit ]]; then
      local Color_On=$Green
    elif [[ "$git_status" =~ nothing\ added\ to\ commit\ but\ untracked\ files\ present ]]; then
      local Color_On=$Purple
    else
      local Color_On=$Red
    fi
    remote=$(git config --get remote.origin.url)
    if echo $remote | grep -q https; then
      repo=$(git config --get remote.origin.url | cut -d'/' -f5 | cut -d'.' -f1)
    else
      repo=$(git config --get remote.origin.url | cut -d'/' -f2 | cut -d'.' -f1)
    fi

    if [[ "$git_status" =~ On\ branch\ ([^[:space:]]+) ]]; then
      branch=${BASH_REMATCH[1]}
    else
      # Detached HEAD. (branch=HEAD is a faster alternative.)
      branch="(`git describe --all --contains --abbrev=4 HEAD 2> /dev/null || echo HEAD`)"
    fi
    # add the result to prompt
    _PROMPT+="${repo}:(${Color_On}${branch}${Color_Off}) "
  else
    # basic information (user@host:path)
    _PROMPT+="${BRed}${uname}${Color_Off}@${BRed}${hname}${Color_Off}:${BPurple}$(dirs -0)${Color_Off} "
  fi

  #TODO(cmkirkla): There is a bug with switching vi modes in bash.  Whenever you switch modes on the 1-line version fo the prompt
  #  (commented out here), the line doesn't full refresh so your cursor puts you in the middle of the bash prompt for editing.
  #echo -e "$_PROMPT\c"
  echo -e "$_PROMPT"
}
PROMPT_COMMAND=__prompt_command

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
  CONF="`PWD`/.wdlaunch.conf"
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
  git_status="`git status -unormal 2>&1`"
  if [[ "$git_status" =~ On\ branch\ ([^[:space:]]+) ]]; then
    branch=${BASH_REMATCH[1]}
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
  PRE='\u203a\u203a\u203a'
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
  PRE='\u203a\u203a\u203a' # Magic carrots
  printf "${PRE} Running ${BLUE}$@${NC}\n"
}

### source aliases to decorate
shopt -s expand_aliases
source ~/.bash_aliases_decorated

### Decorate all aliases to print the underlying command (educational purposes)
while IFS='' read -r ALIAS
do
  ALIAS_NAME=$(echo $ALIAS | cut -d'=' -f1)
  ALIAS_VAL=$(echo $ALIAS | cut -d'=' -f2- | cut -d"'" -f2)
  cmd="alias ${ALIAS_NAME}='print_alias ${ALIAS_NAME} && ${ALIAS_VAL}'"
  eval "$cmd" # THIS LINE DOESN'T WORK!!!
done < <(alias | cut -d' ' -f2-)

# source core aliases (not to be decorated); e.g. ggrep-->grep
source ~/.bash_aliases_core

# ------------------------- INCLUDE OTHER STUFF ----------------------------- #
# source other private and/or machine specific configurations
PLUGIN_DIR=~/.bash
if [ -d "$PLUGIN_DIR" ]; then
  for f in $PLUGIN_DIR/*; do
    source $f
  done
fi

### Added by the Bluemix CLI
source /usr/local/Bluemix/bx/bash_autocomplete

eval $(thefuck --alias fk)
