# ------------------------------
# PATH
# ------------------------------
typeset -U path PATH
[[ -d /usr/local/sbin ]] && path=(/usr/local/sbin $path)
[[ -d $HOME/.local/bin ]] && path=($HOME/.local/bin $path)
[[ -d $HOME/bin ]] && path=($HOME/bin $path)

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

# Homebrew completions must be on FPATH before Oh My Zsh initializes completion.
if [[ $OSTYPE = darwin* ]] && type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
  alias brewup="brew outdated | xargs brew install"
fi

# Plugins
plugins=(
  git
  sudo
)
[[ -d "$ZSH/custom/plugins/zsh-autosuggestions" ]] && plugins+=(zsh-autosuggestions)

if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
else
  print -u2 "Oh My Zsh is not installed; run zsh/setup.sh without --local to install it."
  autoload -Uz compinit
  compinit
fi

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
setopt extendedglob nomatch notify histignorespace globdots
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
# Local overrides (not in repo)
# ------------------------------
[[ -f $ZDOTDIR/.zshrc.local ]] && source $ZDOTDIR/.zshrc.local
