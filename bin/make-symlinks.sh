#!/bin/bash
# Works for installing dotfiles on Ubuntu, CentOS, Fedora, and OSX. Instllation
# on OSX requires installation of `coreutils`:
#   brew install coreutils

# config
PWD=`pwd`
if [ `uname` == "Darwin" ]
then
  HOME=$(greadlink -f ~)  # OSX
else
  HOME=$(readlink -f ~)  # Linux
fi
FILES=(.vimrc .vim .pylintrc)

for FILE in "${FILES[@]}"
do
  # backup file
  if [ -e $HOME/$FILE ]
  then
    mv $HOME/$FILE{,.backup}
  fi

  # link new source
  ln -s $PWD/$FILE $HOME/$FILE
done
