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
    return false
  else
    mv $SRC $TARGET
    return true
  fi
}

# config
PWD=`pwd`
HOME=$($READLINK -f ~)
FILES=(.vimrc .vim .pylintrc)

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
