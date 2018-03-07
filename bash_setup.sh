#!/usr/bin/env bash

BASEDIR=`dirname $0`

[ -e $HOME/.profile ] && mv $HOME/.profile $HOME/.profile.old
[ -e $HOME/.bashrc ] && mv $HOME/.bashrc $HOME/.bashrc.old
[ -e $HOME/.vimrc ] && mv $HOME/.vimrc $HOME/.vimrc.old
[ -e $HOME/.inputrc ] && mv $HOME/.inputrc $HOME/.inputrc.old

ln -s $BASEDIR/.profile $HOME/.profile
ln -s $BASEDIR/.bashrc $HOME/.bashrc
ln -s $BASEDIR/.vimrc $HOME/.vimrc
ln -s $BASEDIR/.inputrc $HOME/.inputrc

unset BASEDIR