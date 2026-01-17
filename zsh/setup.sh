#!/usr/bin/env zsh
# Bootstrap setup script for ZSH environments
# Works on: macOS, Linux, WSL
# Safe to re-run - checks state before making changes

set -e

# Get the directory where this script lives (resolves symlinks)
SCRIPT_DIR="${0:A:h}"

echo "Bootstrap setup from: $SCRIPT_DIR"
echo ""

# Helper: create symlink, backing up existing files
link_file() {
    local src="$1:A"  # Resolve to absolute path
    local dest="$2"
    
    if [[ -L "$dest" ]]; then
        local current=$(readlink -f "$dest" 2>/dev/null || readlink "$dest")
        if [[ "$current" == "$src" ]]; then
            echo "  ✓ $dest (already linked)"
            return
        else
            echo "  → $dest (updating symlink)"
            ln -sf "$src" "$dest"
        fi
    elif [[ -e "$dest" ]]; then
        echo "  → $dest (backing up existing to .old)"
        mv "$dest" "$dest.old"
        ln -s "$src" "$dest"
    else
        echo "  → $dest (created)"
        ln -s "$src" "$dest"
    fi
}

# ------------------------------
# Create ~/.zsh directory
# ------------------------------
if [[ ! -d ~/.zsh ]]; then
    echo "Creating ~/.zsh directory..."
    mkdir -p ~/.zsh
fi

# ------------------------------
# Install oh-my-zsh if missing
# ------------------------------
echo "Checking oh-my-zsh..."
if [[ ! -d ~/.zsh/oh-my-zsh ]]; then
    echo "  Installing oh-my-zsh..."
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git ~/.zsh/oh-my-zsh
else
    echo "  ✓ Already installed"
fi

# ------------------------------
# Install zsh-autosuggestions plugin if missing
# ------------------------------
echo "Checking zsh-autosuggestions..."
if [[ ! -d ~/.zsh/oh-my-zsh/custom/plugins/zsh-autosuggestions ]]; then
    echo "  Installing zsh-autosuggestions..."
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/oh-my-zsh/custom/plugins/zsh-autosuggestions
else
    echo "  ✓ Already installed"
fi

# ------------------------------
# Symlink config files
# ------------------------------
echo "Checking symlinks..."

link_file "$SCRIPT_DIR/.zshenv" ~/.zshenv
link_file "$SCRIPT_DIR/.zshrc" ~/.zsh/.zshrc
link_file "$SCRIPT_DIR/aliases.zsh" ~/.zsh/oh-my-zsh/custom/aliases.zsh
link_file "$SCRIPT_DIR/../.vimrc" ~/.vimrc

# ------------------------------
# Done
# ------------------------------
echo ""
echo "Setup complete!"
echo "Restart your shell or run: source ~/.zshenv && source ~/.zsh/.zshrc"
