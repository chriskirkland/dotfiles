# ------------------------------- SETTINGS ----------------------------------- #
# stop ctrl-q/s from 'bork'ing terminal
stty -ixon

# bash history
export HISTSIZE=1000000
export HISTFILESIZE=200000000

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

# Generates a custom bash prompt with git status, kubernetes context, and exit code indicators.
# This function is called before each prompt is displayed (via PROMPT_COMMAND).
# Parameters: None (uses environment variables and git/kubectl commands)
# Output: Sets PS1 variable with colored prompt showing:
#   - Exit status of previous command (✔ or ✘)
#   - Kubernetes context (with helm symbol ⎈)
#   - Git repository name and branch with color-coded status
#   - User@host:path when not in a git repository
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

# Auto-expands relative paths for the `ln` command to absolute paths.
# This commented-out function parses ln flags and converts relative paths to absolute
# paths before executing the ln command.
# Parameters:
#   -[Ffhinsv]: Standard ln flags
#   path(s): One or more file paths to be linked
# Output: Creates symbolic links using absolute paths
# Example: ln -s ../myfile.txt dest/  (would expand ../myfile.txt to absolute path)
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

# Displays the first and last lines of a file (the "bookends").
# Parameters:
#   $1: Path to the file to display bookends from
# Output: Prints first line and last line of the specified file
# Example: bookends mylog.txt
function bookends()
{
  head -n1 $1
  tail -n1 $1
}

# Monitors ERROR entries in the most recent results log file.
# Navigates to results/ directory, finds the most recent log file matching
# the pattern results-[timestamp].log, and tails it while filtering for ERROR lines.
# Parameters: None
# Output: Continuously streams ERROR lines from the latest results log file
# Example: gerr
function gerr()
{
  cd results/
  logfile=$(ls -1 | grep "results-[0-9]\{10\}.log$" | tail -n 1)
  tail -f -n 2000000 $logfile | grep ERROR
}

# Searches for pattern matches in the most recent results log file.
# Finds the most recent results-[timestamp].log file and continuously tails it
# while filtering for lines matching the provided grep pattern.
# Parameters:
#   $1: Grep pattern to search for (supports Perl regex with -P flag)
# Output: Continuously streams matching lines from the latest results log file
# Example: glog "(ERROR|FAILED|Action|error|Error|ConnectionPool)"
function glog()
{
  # Example usage:
  #   glog "(ERROR|FAILED|Action|error|Error|ConnectionPool)"
  logfile=$(ls -1 results/*.log| grep "results-[0-9]\{10\}.log$" | tail -n 1)
  echo -e "Searching through \"$logfile\"...\n"
  tail -f -n 2000000 $logfile | grep -P $1
}

# Ensures "old"-style Docker daemon is running and connected.
# Checks if docker-machine is stopped and starts it if needed.
# Also ensures the current shell is connected to the docker daemon by
# evaluating the docker-machine environment variables.
# Parameters: None
# Output: Status messages about docker daemon state
# Example: dstart
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

# enable git tab completion
if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi

# Git TimeWarp - moves git commits forward by a specified number of hours.
# This commented-out function would modify commit timestamps to appear as if they
# were made N hours in the future. Currently not working as intended.
# Parameters:
#   $1: Number of hours to move commits forward (must be integer)
# Output: Lists commit hashes and hours adjustment (currently incomplete)
# Example: gtw 24  (would move commits 24 hours forward)
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

# Launches web development workflow for Pug and Sass.
# Sets up file watchers to automatically compile Pug templates to HTML and
# Sass stylesheets to CSS. Configuration can be customized via .wdlaunch.conf
# in the current directory.
# Parameters: None (reads from .wdlaunch.conf if present)
# Configuration defaults:
#   PUG_FROM_DIR="pug"    - Source directory for Pug templates
#   PUG_TO_DIR="."        - Output directory for HTML files
#   SASS_FROM_DIR="sass"  - Source directory for Sass files
#   SASS_TO_DIR="css"     - Output directory for CSS files
# Output: Starts background watchers for Pug and Sass compilation
# Example: wdlaunch
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

# Git Update Branch - updates current branch from the appropriate remote.
# Automatically determines the "best" remote to fetch from based on priority:
# local upstream config > "upstream" > "origin" > "cmkirkla" > first remote
# Then performs a fast-forward only merge from that remote.
# Parameters: None
# Output:
#   - Displays the git fetch and merge command being executed
#   - Error message if not on a branch or not in a git repository
# Example: gub
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

# Prints the underlying command for a bash alias.
# Extracts and displays the actual command that an alias executes, useful for
# educational purposes and debugging.
# Parameters:
#   $@: Name of the alias to print
# Output: Formatted display of the alias's underlying command
# Example: print_alias gs  (would show the command behind the 'gs' alias)
function print_alias() {
  #TODO(cmkirkla): include trailing command line args
  pretty_print "$(alias $@ | cut -d"'" -f2 | cut -d";" -f2- | cut -d'&' -f3-| xargs)"
}

# Prints a formatted message indicating a command is being run.
# Displays the provided text in blue with arrow symbols (›››) as a prefix.
# Parameters:
#   $@: Command or message to display
# Output: Formatted message like "››› Running <command>"
# Example: pretty_print "git status"
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
#source /usr/local/Bluemix/bx/bash_autocomplete

eval $(thefuck --alias fk)

eval $(thefuck --alias)

### github helpers

# Internal helper function for cloning GitHub repositories.
# Clones a GitHub repository into the standardized directory structure:
# $HOME/git/src/github.com/<org>/<repo>
# Creates the organization directory if it doesn't exist. If repository already
# exists, just navigates into it.
# Parameters:
#   $1: Repository in format "org/repo" or just "repo" (defaults to "github" org)
# Output:
#   - Status messages about directory navigation and cloning
#   - Changes current directory to the cloned repository
# Returns: 0 on success
# Example: gcr_inner github/dotfiles
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

  local partsArr=(${ORG_AND_REPO//\// })
  local ORG=${partsArr[0]}
  local REPO=${partsArr[1]}

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

# Git Clone Repository - clones a GitHub repository and navigates into it.
# Wrapper around gcr_inner that handles failures gracefully by returning to the
# previous directory if the clone fails.
# Parameters:
#   $1: Repository in format "org/repo" or just "repo" (defaults to "github" org)
# Output:
#   - Status messages from gcr_inner
#   - Error message if clone fails
# Example: gcr chriskirkland/dotfiles
function gcr() {
  # if the new repo checkout fails, put us back into our previous pwd
  if ! gcr_inner $1; then
    echo "repo clone failed. backing out..."
    cd $PREVIOUS_DIR
  fi
}

# Opens the current repository in browser (ORB = Open Repo in Browser).
# Determines the GitHub organization and repository name from the current git
# repository and opens the GitHub page in the default browser.
# Parameters: None (uses current git repository)
# Output: Opens browser to https://github.com/<org>/<repo>
# Example: orb
function orb() {
  # open repo in browser
  local ORG_AND_REPO=$(git rev-parse --show-toplevel | rev | cut -d '/' -f1-2 | rev)
  open "https://github.com/$ORG_AND_REPO"
}

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
