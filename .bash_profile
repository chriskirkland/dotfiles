#!/bin/bash
if [ -f ~/.bashrc ]; then . ~/.bashrc; fi

# performance stuff
# ulimit -n 65536 65536

export PATH=$HOME/.vim/bin:$PATH

# ruby stuff
[[ -s "/Users/chriskirkland/.gvm/scripts/gvm" ]] && source "/Users/chriskirkland/.gvm/scripts/gvm"
export PATH=$HOME/.rbenv/shims:$PATH

# don't ask for pwd for default SSH key
ssh-add -K ~/.ssh/id_ed25519
export PATH="/usr/local/sbin:$PATH"

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
