#!/usr/bin/env bash

# symlink all *.bash files from $HOME/.bashrc.avail to $HOME/.bashrc.d/
ln -sf $HOME/.bashrc.avail/*.bash $HOME/.bashrc.d/
