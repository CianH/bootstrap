# ZSH configuration - interactive shell settings
# (PATH and environment variables are in .zprofile)

# ------------------------------
# Oh My ZSH
# ------------------------------
export ZSH="$ZDOTDIR/oh-my-zsh"
ZSH_THEME="robbyrussell"
CASE_SENSITIVE="true"

# Update settings
zstyle ':omz:update' mode reminder
zstyle ':omz:update' frequency 30
zstyle ':omz:update' verbosity silent

# Plugins
plugins=(
  git
  sudo
  dirhistory
  zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# ------------------------------
# Prompt customization
# ------------------------------
# Show hostname in prompt when in SSH session
if [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
  PROMPT='%F{green}%m%f:'$PROMPT
fi

# ------------------------------
# Shell options
# ------------------------------
setopt extendedglob nomatch notify histignorespace
unsetopt autocd beep
bindkey -e

# ------------------------------
# History
# ------------------------------
HISTFILE=$ZDOTDIR/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt hist_ignore_all_dups  # Remove older duplicate entries from history
setopt hist_reduce_blanks    # Remove superfluous blanks from history items
setopt share_history         # Share history between all sessions

# ------------------------------
# macOS specific
# ------------------------------
if [[ $OSTYPE = darwin* ]]; then
  alias brewup="brew outdated | xargs brew install"
  
  # Homebrew completions (must be before compinit)
  if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
  fi
fi

# ------------------------------
# Completion
# ------------------------------
zstyle :compinstall filename "$ZDOTDIR/.zshrc"
autoload -Uz compinit
compinit

# ------------------------------
# Local overrides (not in repo)
# ------------------------------
[[ -f $ZDOTDIR/.zshrc.local ]] && source $ZDOTDIR/.zshrc.local
