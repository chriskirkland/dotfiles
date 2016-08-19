FROM centos:latest
MAINTAINER docker@ekito.fr

# install OS dependencies
# RUN apt-get -y update && apt-get install -y vim git
RUN yum install -y vim git

# install Vundle
RUN cd ~ && \
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim && \
    vim +PluginInstall +qall

# setup dotfiles
RUN cd ~ && \
    git clone https://github.com/chriskirkland/dotfiles.git && \
    cd dotfiles && \
    bin/make-symlinks.sh
