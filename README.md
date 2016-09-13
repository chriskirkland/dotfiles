# dotfiles
vim and bash customizations

## Installation
```
git clone git@github.com:chriskirkland/dotfiles.git
bin/make-symlinks.sh
```

## Test out customization (Docker)

Install docker (https://docs.docker.com/engine/installation/)

Build docker image and launch container: 

```
docker build -t dotfiles .
docker run -i -t dotfiles /bin/bash
```
