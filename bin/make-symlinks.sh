#!/bin/bash

# config
PWD=`pwd`
HOME=$(readlink -f ~)
FILES=(.vimrc .vim .pylintrc)

for FILE in "${FILES[@]}"
do
  # backup file
  if [ -e $HOME/$FILE ];
  then
    mv $HOME/$FILE{,.backup}
  fi

  # link new source
  ln -s $PWD/$FILE $HOME/$FILE
done
