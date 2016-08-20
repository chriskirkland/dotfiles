FROM ubuntu:latest
MAINTAINER docker@ekito.fr

# install OS dependencies
RUN apt-get -y update && apt-get install -y vim git

# setup dotfiles
RUN cd ~ && \
    git clone https://github.com/chriskirkland/dotfiles.git && \
    cd dotfiles && \
    bin/make-symlinks.sh

# install Vundle + other plugins
RUN cd ~ && \
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim && \
    vim +PluginInstall +qall
