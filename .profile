export PATH=.:~/bin:/usr/local/sbin:$PATH

case "${OSTYPE}" in
  # Mac(Unix)
  darwin*)
    #[ -f ~/.bash/bashrc.darwin ] && source ~/.bash/bashrc.darwin
    export HOMEBREW_NO_ANALYTICS=1
    alias brewup="brew outdated | xargs brew install"
    # homebrew 
    if [ -f $(brew --prefix)/etc/bash_completion ]; then
      . $(brew --prefix)/etc/bash_completion
    fi

    if [ -f ~/.bashrc ]; then
      . ~/.bashrc
    fi
    ;;
  # Linux
  linux*)
    #[ -f ~/.bash/bashrc.linux ] && source ~/.bash/bashrc.linux
    setterm -blength 0
    ;;
esac

# history settings
export HISTCONTROL=ignoreboth #this is the same as ignorespace:ignoredups
export HISTSIZE=1000
export HISTFILESIZE=2000
export HISTIGNORE="history*:ls:pwd"

# load private extras
if [ -f ~/.bash_extras ]; then 
  . ~/.bash_extras 
fi

if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi
