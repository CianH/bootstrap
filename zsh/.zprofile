# ZSH profile - loaded once for login shells

# ------------------------------
# macOS specific
# ------------------------------
if [[ $OSTYPE = darwin* ]]; then
  # Homebrew setup (Apple Silicon and Intel paths)
  [[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
  [[ -f /usr/local/bin/brew ]] && eval "$(/usr/local/bin/brew shellenv)"
  
  export HOMEBREW_NO_ANALYTICS=1
fi
