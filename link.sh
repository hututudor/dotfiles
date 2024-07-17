#!/bin/sh

set -xe

if [ ! -L ~/.tmux.conf ]; then 
  ln -s $(pwd)/config_files/.tmux.conf ~/.tmux.conf 
fi

if [ ! -L ~/.zshown ]; then
  append_file=data/zsh_append.sh
  append=$(cat $append_file)
  if ! grep -qF "$(head -1 $append_file)" ~/.zshrc; then
    echo "$append" >> ~/.zshrc 
  fi 

  ln -s $(pwd)/config_files/.zshown ~/.zshown
fi