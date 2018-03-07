exists() { test -x "$(command -v "$1")"; }

export PATH=".:$HOME/bin:/usr/local/sbin:$PATH"

export EDITOR=vi
exists vim && EDITOR=vim

if [[ $OSTYPE = darwin* ]]; then
    # homebrew
    export HOMEBREW_NO_ANALYTICS=1
    alias brewup="brew outdated | xargs brew install"
    if [ -f $(brew --prefix)/etc/bash_completion ]; then
      . $(brew --prefix)/etc/bash_completion
    fi
    ;;
fi

# if running bash
if [ -n "$BASH_VERSION" ]; then
  if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
  fi
  if [ -f ~/.bash_extras ]; then
    . ~/.bash_extras
  fi
fi