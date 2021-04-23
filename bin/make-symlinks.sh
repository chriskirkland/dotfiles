#!/bin/bash
# Works for installing dotfiles on Ubuntu, CentOS, Fedora, and OSX. Instllation
# on OSX requires installation of `coreutils`:
#   brew install coreutils
if [ `uname` == "Darwin" ]
then
  READLINK=greadlink
else
  READLINK=readlink
fi

# Tries to backup $SRC file to $TARGET. Returns whether backup was successful.
try_backup() {
  SRC=$1
  TARGET=$2

  if [ -e $TARGET ] && diff $SRC $TARGET;
  then
    return 1
  else
    mv $SRC $TARGET
    return 0
  fi
}

mkdir -p ~/.vim/after/ftplugin

# config
PWD=`pwd`
HOME=$($READLINK -f ~)
FILES=(.bashrc .bash_profile .bash_aliases_decorated .bash_aliases_core .gitconfig .inputrc .vimrc .vim .pylintrc `ls .vim/after/ftplugin/*`)

# install files
for FILE in "${FILES[@]}"
do
  # backup file
  TARGET=$HOME/$FILE
  LOOP=1
  while ! try_backup $HOME/$FILE $TARGET;
  do
    TARGET="$HOME/$FILE~$LOOP"
    ((LOOP++))
  done

  # link new source
  ln -s $PWD/$FILE $HOME/$FILE
done
