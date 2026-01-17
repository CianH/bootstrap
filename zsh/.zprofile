# ZSH profile - loaded once for login shells
# Environment variables and PATH setup

# ------------------------------
# PATH
# ------------------------------
[[ -d $HOME/bin ]] && export PATH="$HOME/bin:$PATH"
[[ -d $HOME/.local/bin ]] && export PATH="$HOME/.local/bin:$PATH"
[[ -d /usr/local/sbin ]] && export PATH="/usr/local/sbin:$PATH"

# ------------------------------
# Environment
# ------------------------------
export EDITOR='vim'
export DOTNET_CLI_TELEMETRY_OPTOUT=1

# ------------------------------
# macOS specific
# ------------------------------
if [[ $OSTYPE = darwin* ]]; then
  # Homebrew setup (Apple Silicon and Intel paths)
  [[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
  [[ -f /usr/local/bin/brew ]] && eval "$(/usr/local/bin/brew shellenv)"
  
  export HOMEBREW_NO_ANALYTICS=1
fi
