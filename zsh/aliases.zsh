# Shared aliases - symlink to $ZSH_CUSTOM/aliases.zsh

# listing
alias la="ls -lah"
alias ll="ls -lah"
alias l="ls -lh"

# navigation
alias cd..="cd .."
alias h="history"

# safety
alias mv="mv -nv"

# macOS specific
[[ $OSTYPE = darwin* ]] && alias lockscreen='/System/Library/CoreServices/"Menu Extras"/User.menu/Contents/Resources/CGSession -suspend'
