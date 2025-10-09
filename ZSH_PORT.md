# Zsh Configuration Port

This document describes the port of the bash configuration to zsh.

## Files Created

- `.zshrc` - Main zsh configuration file (ported from `.bashrc`)
- `.zsh_aliases_decorated` - Decorative aliases for zsh (ported from `.bash_aliases_decorated`)
- `.zsh_aliases_core` - Core aliases for zsh (ported from `.bash_aliases_core`)

## Key Differences from Bash

### History Settings

**Bash:**
```bash
export HISTSIZE=1000000
export HISTFILESIZE=200000000
```

**Zsh:**
```zsh
export HISTSIZE=1000000
export SAVEHIST=200000000
export HISTFILE=~/.zsh_history
# Additional zsh history options
setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
```

Zsh provides more granular control over history behavior through various options.

### Prompt Command

**Bash:**
```bash
PROMPT_COMMAND=__prompt_command
```

**Zsh:**
```zsh
function precmd() {
  # prompt setup code
}
```

Zsh uses the `precmd` hook function instead of `PROMPT_COMMAND`.

### Regular Expression Matching

**Bash:**
```bash
if [[ "$git_status" =~ On\ branch\ ([^[:space:]]+) ]]; then
  branch=${BASH_REMATCH[1]}
fi
```

**Zsh:**
```zsh
if [[ "$git_status" =~ "On branch "([^[:space:]]+) ]]; then
  branch=${match[1]}
fi
```

Zsh uses `${match[1]}` instead of `${BASH_REMATCH[1]}`.

### String Splitting

**Bash:**
```bash
local partsArr=(${ORG_AND_REPO//\// })
local ORG=${partsArr[0]}
local REPO=${partsArr[1]}
```

**Zsh:**
```zsh
local partsArr=("${(@s:/:)ORG_AND_REPO}")
local ORG=${partsArr[1]}
local REPO=${partsArr[2]}
```

Zsh uses parameter expansion flags `(@s:/:)` for splitting, and arrays are 1-indexed instead of 0-indexed.

### Alias Expansion

**Bash:**
```bash
shopt -s expand_aliases
```

**Zsh:**
Aliases are always expanded in zsh by default, so no special configuration is needed.

### Completion System

**Bash:**
```bash
if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi
```

**Zsh:**
```zsh
autoload -Uz compinit && compinit -u
```

Zsh has a built-in completion system that's loaded with `compinit`. The `-u` flag allows using insecure directories (useful in development environments).

### Plugin Directory

**Bash:**
- Plugins loaded from `~/.bash/`

**Zsh:**
- Plugins loaded from `~/.zsh/`

## Features Ported

### Environment Variables
- ✅ History configuration (HISTSIZE, SAVEHIST, HISTFILE)
- ✅ Go environment (GOPATH, GO111MODULE, GOPRIVATE)
- ✅ Ruby paths
- ✅ Ansible settings
- ✅ Terminal coloring (CLICOLOR, LSCOLORS)

### Functions
- ✅ `bookends()` - Display first and last lines of a file
- ✅ `gerr()` - Search log files for errors
- ✅ `glog()` - Search log files with pattern
- ✅ `dstart()` - Start docker daemon
- ✅ `wdlaunch()` - Web development workflow launcher
- ✅ `gub()` - Git update branch
- ✅ `gcr_inner()` / `gcr()` - GitHub clone and enter repo
- ✅ `orb()` - Open repo in browser
- ✅ `pretty_print()` - Pretty print commands
- ✅ `print_alias()` - Print alias commands

### Aliases
All aliases from bash have been ported, including:
- ✅ General shortcuts (cd helpers, ls, clear, vim)
- ✅ Git aliases (ga, gb, gc, gd, etc.)
- ✅ Kubernetes aliases (k, kg, kd, etc.)
- ✅ Golang test and format aliases
- ✅ Ruby aliases
- ✅ OSX-specific GNU utility remappings

### Custom Prompt
The custom prompt has been ported to use zsh's `precmd` hook, displaying:
- Exit status indicator (✔/✘)
- Kubernetes context (⎈)
- Git repository and branch status with color coding

## Known Issues

### Alias Decoration
The alias decoration loop that attempts to wrap aliases with `print_alias` doesn't work properly in either bash or zsh (as noted in the original `.bashrc` with "THIS LINE DOESN'T WORK!!!"). This section has been commented out in the zsh version to preserve alias functionality.

## Installation

To install the zsh configuration:

```bash
cd ~/dotfiles
bin/make-symlinks.sh
```

This will create symlinks for both bash and zsh configuration files.

## Testing

You can test the zsh configuration without affecting your current shell:

```bash
# Test syntax
zsh -n ~/.zshrc

# Test in a new zsh session
zsh -c "source ~/.zshrc && alias | head -20"

# Or start an interactive zsh session
zsh
```

## Migration from Bash

To switch from bash to zsh:

1. Install zsh if not already installed:
   ```bash
   # Ubuntu/Debian
   sudo apt-get install zsh
   
   # macOS (usually pre-installed)
   brew install zsh
   ```

2. Change your default shell:
   ```bash
   chsh -s $(which zsh)
   ```

3. Log out and log back in for the change to take effect.

## Compatibility

The ported configuration maintains compatibility with:
- Linux (Ubuntu, CentOS, Fedora)
- macOS (with GNU coreutils installed)
- Docker containers

All core functionality from the bash configuration has been preserved and adapted to zsh idioms.
