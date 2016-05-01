export PATH=.:~/bin:/usr/local/sbin:$PATH
export HOMEBREW_NO_ANALYTICS=1

# aliases
alias la="ls -lah"
alias l="ls -lh"
alias cd..="cd .." # common typo
alias h="history"
alias mv="mv -nv" # make mv safer

# homebrew 
if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi

# history settings
export HISTCONTROL=ignoreboth #this is the same as ignorespace:ignoredups
export HISTSIZE=500
export HISTIGNORE="history*:ls:pwd"

# load private extras
if [ -f ~/.bash_extras  ]; then 
  . ~/.bash_extras 
fi
