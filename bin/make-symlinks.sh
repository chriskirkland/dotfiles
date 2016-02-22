#!/bin/bash

# config
PWD=`pwd`
HOME=$(readlink -f ~)

# make backups
if [ -e $HOME/.vimrc ];
then
	mv $HOME/.vimrc $HOME/.vimrc.backup
fi
if [ -e $HOME/.vim ];
then
	mv $HOME/.vim $HOME/.vim.backup
fi

# make links
ln -s $PWD/.vimrc $HOME/.vimrc
ln -s $PWD/.vim $HOME/.vim
