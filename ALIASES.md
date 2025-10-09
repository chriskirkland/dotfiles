# Bash Aliases Documentation

This document provides a comprehensive reference for all bash aliases defined in this dotfiles configuration.

## Table of Contents

- [General Navigation & Utilities](#general-navigation--utilities)
- [Git Aliases](#git-aliases)
- [Kubernetes Aliases](#kubernetes-aliases)
- [IBM Container Service](#ibm-container-service)
- [Golang Development](#golang-development)
- [Ruby Development](#ruby-development)
- [OSX-Specific Aliases](#osx-specific-aliases)

---

## General Navigation & Utilities

| Alias | Command | Description |
|-------|---------|-------------|
| `hg` | `history \| grep` | Search through command history (note: use Ctrl+R for reverse search as an alternative) |
| `..` | `cd ..` | Navigate up one directory level |
| `...` | `cd ../..` | Navigate up two directory levels |
| `....` | `cd ../../..` | Navigate up three directory levels |
| `.....` | `cd ../../../..` | Navigate up four directory levels |
| `......` | `cd ../../../../..` | Navigate up five directory levels |
| `l` | `ls` | List directory contents (shorthand) |
| `c` | `clear` | Clear the terminal screen |
| `ve` | `vim ~/.vimrc` | Edit Vim configuration file |
| `vb` | `vim ~/.bashrc` | Edit Bash configuration file |
| `sb` | `source ~/.bashrc` | Reload Bash configuration |
| `mhg` | `\hg` | Access Mercurial `hg` command (bypasses the history grep alias) |
| `pjq` | `pbpaste \| jq .` | Format JSON from clipboard using jq |

### Usage Examples

```bash
# Navigate up multiple levels quickly
cd /path/to/deep/directory/structure
...  # Takes you to /path/to/deep

# Search command history
hg docker  # Find all commands containing 'docker'

# Edit and reload bash config
vb  # Edit .bashrc
sb  # Apply changes without restarting terminal
```

---

## Git Aliases

All git aliases include tab completion support for enhanced productivity.

| Alias | Command | Description |
|-------|---------|-------------|
| `ga` | `git add` | Stage files for commit |
| `gb` | `git branch` | List, create, or delete branches |
| `gc` | `git diff --check && git commit` | Check for whitespace errors before committing |
| `gd` | `git diff` | Show unstaged changes |
| `gdm` | `git diff main` | Show differences between current branch and main |
| `gdc` | `git diff --cached` | Show staged changes |
| `gdmc` | `git diff main --cached` | Show staged differences between current branch and main |
| `gk` | `git checkout` | Switch branches or restore files |
| `gkm` | `git checkout main \|\| git checkout master` | Switch to main branch (falls back to master if main doesn't exist) |
| `gl` | `git lol -20` | Show last 20 commits with custom log format |
| `gs` | `git status -uno` | Show status without listing untracked files |
| `gsall` | `git status` | Show full git status including untracked files |

### Usage Examples

```bash
# Stage and commit workflow
ga .                    # Stage all changes
gc -m "Add feature"     # Check for issues and commit

# Check differences
gd                      # View unstaged changes
gdc                     # View what will be committed
gdm                     # Compare current work with main branch

# Branch management
gkm                     # Return to main branch
gb feature-branch       # Create new branch
gk feature-branch       # Switch to branch

# Status checking
gs                      # Quick status (ignores untracked files)
gsall                   # Full status
```

---

## Kubernetes Aliases

These aliases streamline common kubectl operations.

| Alias | Command | Description |
|-------|---------|-------------|
| `k` | `kubectl` | Shorthand for kubectl |
| `kg` | `kubectl get` | Get resources |
| `kga` | `kubectl get --all-namespaces` | Get resources across all namespaces |
| `kd` | `kubectl describe` | Show detailed information about a resource |
| `kt` | `kubectl delete` | Delete resources |
| `ke` | `kubectl edit` | Edit resources in default editor |
| `kx` | `kubectl exec` | Execute command in a container |
| `kuc` | `kubectl config use-context` | Switch to a different cluster context |
| `kgc` | `kubectl config get-clusters` | List all available clusters |
| `krc` | `export KUBECONFIG=~/.kube/armada/kubeconfig` | Set kubeconfig to armada configuration |
| `ks` | `kubectl config set-context $(kubectl config current-context) --namespace` | Set namespace for current context |
| `ksk` | `kubectl config set-context $(kubectl config current-context) --namespace kube-system` | Switch to kube-system namespace |
| `ksa` | `kubectl config set-context $(kubectl config current-context) --namespace armada` | Switch to armada namespace |
| `ksd` | `kubectl config set-context $(kubectl config current-context) --namespace default` | Switch to default namespace |
| `ckube` | `ckube --kubeconfig $KUBECONFIG` | Run ckube with current kubeconfig |

### Usage Examples

```bash
# Resource management
kg pods                 # List pods in current namespace
kga pods                # List all pods across all namespaces
kd pod my-pod           # Describe a specific pod
kt pod my-pod           # Delete a pod

# Namespace switching
ksk                     # Switch to kube-system namespace
ksa                     # Switch to armada namespace
ksd                     # Switch to default namespace
ks my-namespace         # Switch to custom namespace

# Cluster context management
kgc                     # List available clusters
kuc production          # Switch to production cluster

# Container interaction
kx my-pod -- /bin/bash  # Open shell in a pod
```

---

## IBM Container Service

| Alias | Command | Description |
|-------|---------|-------------|
| `cs` | `bx cs` | IBM Bluemix container service shorthand |
| `blsa` | `bx login -a https://api.stage1.ng.bluemix.net --apikey` | Login to Bluemix staging environment |
| `blpa` | `bx login -a https://api.ng.bluemix.net --apikey` | Login to Bluemix production environment |

### Usage Examples

```bash
# Login to environments
blsa YOUR_API_KEY       # Login to staging
blpa YOUR_API_KEY       # Login to production

# Container service operations
cs clusters             # List clusters
```

---

## Golang Development

| Alias | Command | Description |
|-------|---------|-------------|
| `gtc` | `go test -cover $(go list ./... \| grep -v /vendor/)` | Run tests with coverage for all non-vendor packages |
| `gti` | `go test -gcflags=-l` | Run tests with inlining disabled (useful for debugging) |
| `gth` | `go test -coverprofile=/tmp/coverage.out && go tool cover -html=/tmp/coverage.out` | Generate and open HTML coverage report |
| `gfa` | `go fmt $(go list ./... \| grep -v /vendor/)` | Format all non-vendor Go files |
| `de` | `dep ensure -v` | Run dep ensure with verbose output |
| `dea` | `dep ensure -v -add` | Add dependency with dep |
| `gogrep` | `grep --include=*.go --exclude=*_test.go --exclude-dir=vendor -r` | Search Go source files (excluding tests and vendor) |
| `gogrepit` | `grep --include=*.go --exclude-dir=vendor -r` | Search all Go files including tests (excluding vendor) |
| `rbgrep` | `grep --include=*.rb --exclude-dir=test --exclude-dir=vendor --exclude-dir=db -r` | Search Ruby source files (excluding tests, vendor, and db) |
| `rbgrepit` | `grep --include=*.rb --exclude-dir=vendor --exclude-dir=db -r` | Search all Ruby files including tests (excluding vendor and db) |

### Usage Examples

```bash
# Testing
gtc                     # Run all tests with coverage
gti                     # Run tests (good for debugging)
gth                     # Generate and view HTML coverage report

# Code formatting
gfa                     # Format all Go code

# Code search
gogrep "functionName"   # Search for function in source files
gogrepit "TODO"         # Search for TODO in all Go files including tests

# Dependency management
de                      # Update dependencies
dea github.com/pkg/errors  # Add new dependency
```

---

## Ruby Development

| Alias | Command | Description |
|-------|---------|-------------|
| `irb` | `irb -I .` | Start IRB with current directory in load path |

### Usage Examples

```bash
# Interactive Ruby shell
irb                     # Start IRB with local context
```

---

## OSX-Specific Aliases

These aliases are only defined on macOS systems and remap native macOS utilities to their GNU equivalents for consistency with Linux.

**Prerequisites:** Requires Homebrew and `coreutils` package:
```bash
brew install coreutils
brew install gnu-getopt
```

| Alias | Command | Description |
|-------|---------|-------------|
| `grep` | `ggrep` | Use GNU grep instead of BSD grep |
| `date` | `gdate` | Use GNU date instead of BSD date |
| `readlink` | `greadlink` | Use GNU readlink instead of BSD readlink |
| `getopt` | `/usr/local/Cellar/gnu-getopt/1.1.6/bin/getopt` | Use GNU getopt |
| `vim` | `mvim -v` | Use MacVim in terminal mode |

### Usage Examples

```bash
# These work exactly like their GNU counterparts
grep -P 'pattern' file  # Perl-compatible regex (not available in BSD grep)
date -d '2 days ago'    # Relative date parsing (GNU syntax)
readlink -f path        # Canonicalize path (GNU behavior)
```

### Important Notes

- These aliases ensure consistent behavior across macOS and Linux environments
- Scripts written with these aliases will behave consistently on both platforms
- The `ggrep`, `gdate`, and `greadlink` commands must be installed via Homebrew's `coreutils` package

---

## Additional Functions

While not aliases, these bash functions are also available and worth noting:

- **`gub`**: Git Update Branch - fetches and fast-forward merges from upstream
- **`gcr <org/repo>`**: Git Clone Repo - clones a GitHub repository into structured directory
- **`orb`**: Open Repo in Browser - opens current git repo in web browser
- **`bookends <file>`**: Shows first and last line of a file
- **`glog <pattern>`**: Search through latest log file for pattern
- **`gerr`**: Tail latest log file for ERROR entries
- **`dstart`**: Start and connect to Docker daemon
- **`wdlaunch`**: Launch web development workflow (pug/sass compilation)

For more details on these functions, see the `.bashrc` file.

---

## Notes

1. **Decorated Aliases**: Most aliases are "decorated" to print the underlying command before execution for educational purposes. This is handled by the `print_alias` function in `.bashrc`.

2. **Core Aliases**: Some aliases in `.bash_aliases_core` are not decorated to avoid circular dependencies (e.g., `ggrep` -> `grep`).

3. **Git Autocompletion**: Git aliases have tab completion enabled through `__git_complete` functions.

4. **Extensibility**: Additional aliases can be added by placing scripts in `~/.bash/` directory, which are automatically sourced.
