# ------------------------------- SETTINGS ----------------------------------- #
# stop ctrl-q/s from 'bork'ing terminal
stty -ixon

# bash history
HISTSIZE=10000
HISTFILESIZE=20000

# general
alias hg='history | grep'  # should use rev-search in place of this...
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias l='ls'
alias c='clear'
alias ve='vim ~/.vimrc'
alias vb='vim ~/.bashrc'
alias sb='source ~/.bashrc'
alias mhg='\hg'  # give access to mercurial 'hg'

# git
alias ga='git add'
alias gb='git branch'
alias gc='git commit'
alias gd='git diff'
alias gdc='git diff --cached'
alias gh='git heh -20'
alias gk='git checkout'
alias gl='git lol -20'
alias gs='git status -uno'
alias gsall='git status'

# golang
export GOPATH="$HOME/git/"
export GOROOT=/usr/local/opt/go/libexec
export PATH=$PATH:$GOPATH/bin:$GOROOT/bin

# cron
export EDITOR=vim

# OSX specific
if [ `uname` == "Darwin" ]
then
  # remap Mac --> GNU utils
  # requires Homebrew coreutils (`brew install coreutils`)
  alias grep='ggrep'
  alias date='gdate'
  alias readlink='greadlink'

  # install gnu-getopt
  #   ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null 2> /dev/null
  #   brew install gnu-getopt
  alias getopt='/usr/local/Cellar/gnu-getopt/1.1.6/bin/getopt'

  # macvim
  alias vim='mvim -v'
fi

# ------------------------------ TERMINAL SETTINGS --------------------------- #
# terminal coloring
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
# prompt style
export PS1="[\@] \u> "

# FROM http://www.terminally-incoherent.com/blog/2013/01/14/whats-in-your-bash-prompt/
# Colors
Color_Off="\033[0m"
Red="\033[0;31m"
Green="\033[0;32m"
Purple="\033[0;35m"
# local config
uname="cmkirkla"
hname="mymbp"
# set up command prompt
function __prompt_command()
{
    # capture the exit status of the last command
    EXIT="$?"
    PS1=""

    if [ $EXIT -eq 0 ]; then PS1+="\[$Green\][\!]\[$Color_Off\] "; else PS1+="\[$Red\][\!]\[$Color_Off\] "; fi

    # if logged in via ssh shows the ip of the client
    if [ -n "$SSH_CLIENT" ]; then PS1+="\[$Yellow\]("${$SSH_CLIENT%% *}")\[$Color_Off\]"; fi

    # debian chroot stuff (take it or leave it)
    PS1+="${debian_chroot:+($debian_chroot)}"

    # basic information (user@host:path)
    #PS1+="\[$BRed\]\u\[$Color_Off\]@\[$BRed\]\h\[$Color_Off\]:\[$BPurple\]\w\[$Color_Off\] "
    PS1+="\[$BRed\]$uname\[$Color_Off\]@\[$BRed\]$hname\[$Color_Off\]:\[$BPurple\]\w\[$Color_Off\] "

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
        if [[ "$git_status" =~ On\ branch\ ([^[:space:]]+) ]]; then
            branch=${BASH_REMATCH[1]}
        else
            # Detached HEAD. (branch=HEAD is a faster alternative.)
            branch="(`git describe --all --contains --abbrev=4 HEAD 2> /dev/null || echo HEAD`)"
        fi
        # add the result to prompt
        PS1+="\[$Color_On\][$branch]\[$Color_Off\] "
    fi
    # prompt $ or # for root
    PS1+="\$ "
}
PROMPT_COMMAND=__prompt_command

# -------------------------- UTILITY FUNCTIONS ------------------------------ #
# auto-expand relative paths for `ln`
function ln()
{
  # argument parsing strategy taking adapted from
  #   http://unix.stackexchange.com/a/156231

  # parse flags
  parsed_options=$(getopt -o Ffhinsv -- "$@")
	eval "set -- $parsed_options"
  FLAGS=""
	while [ "$#" -gt 0 ]; do
    case $1 in
      (-[Ffhinsv]) FLAGS="$FLAGS $1"; shift;;
      (--) shift; break;;
      (*) exit 1 # should never be reached.
    esac
  done

  # parse non-flag arguments and expand paths
  PATHS=""
  while [ "$#" -gt 0 ]; do
    PATHS="$PATHS $(readlink -f $1)"
    shift
  done

  # run command
  eval "ln \"$FLAGS\" \"$PATHS\""
}

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
#     HOURS=$1
#     if ! [[ $HOURS =~ ^[0-9]+$ ]]  # not an integer
#     then
#         echo "Expected integer but found \"$HOURS\". Exiting..."
#         return 1
#     fi
#
#     for COMMIT_HASH in $(git show origin/master..HEAD -q | grep -P "^commit" | grep -Po "[a-f0-9]{40}")
#     do
#         echo $COMMIT_HASH $HOURS
#     done
# }

# ------------------------- INCLUDE OTHER STUFF ----------------------------- #
# source other private and/or machine specific configurations
for f in ~/.bash/*; do
  source $f
done
