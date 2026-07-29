#!/usr/bin/env zsh
# Bootstrap setup script for ZSH environments
# Works on: macOS, Linux, WSL
# Safe to re-run - checks state before making changes
#
# Usage:
#   ./setup.sh              # Normal setup (clones plugins if missing)
#   ./setup.sh --local      # Skip network operations (symlinks only)

typeset -a SETUP_FAILURES=()

record_failure() {
    SETUP_FAILURES+=("$1")
}

run_step() {
    local description="$1"
    shift
    if ! "$@"; then
        record_failure "$description"
    fi
}

# Get the directory where this script lives (resolves symlinks)
SCRIPT_DIR="${0:A:h}"
LOCAL_MODE=false

# Parse arguments
if [[ "$1" == "--local" ]]; then
    LOCAL_MODE=true
fi

# Ensure common paths are available (some environments have minimal default PATH)
export PATH="/usr/local/bin:$PATH"

echo "Bootstrap setup from: $SCRIPT_DIR"
echo ""

# Helper: create symlink, backing up existing files/content
link_file() {
    local src="${1:A}"  # Resolve to absolute path
    local dest="$2"
    
    if [[ -L "$dest" ]]; then
        local current=$(readlink -f "$dest" 2>/dev/null || readlink "$dest")
        if [[ "$current" == "$src" ]]; then
            echo "  ✓ $dest (already linked)"
            return
        fi
        # Symlink points elsewhere - check if target exists
        if [[ -e "$dest" ]]; then
            if [[ -e "$dest.old" || -L "$dest.old" ]]; then
                echo "  ! Cannot replace $dest: backup already exists at $dest.old" >&2
                return 1
            fi
            # Target exists, archive the content before replacing
            echo "  → $dest (archiving old target to .old)"
            if ! cp -rL "$dest" "$dest.old"; then
                echo "  ! Failed to archive existing target for $dest" >&2
                return 1
            fi
        else
            echo "  → $dest (removing broken symlink)"
        fi
        if ! rm -f "$dest"; then
            echo "  ! Failed to remove existing symlink at $dest" >&2
            return 1
        fi
        if ! ln -s "$src" "$dest"; then
            echo "  ! Failed to create symlink at $dest" >&2
            return 1
        fi
        echo "  ✓ $dest (created)"
    elif [[ -e "$dest" ]]; then
        if [[ -e "$dest.old" || -L "$dest.old" ]]; then
            echo "  ! Cannot replace $dest: backup already exists at $dest.old" >&2
            return 1
        fi
        echo "  → $dest (backing up existing to .old)"
        if ! mv "$dest" "$dest.old"; then
            echo "  ! Failed to archive existing path at $dest" >&2
            return 1
        fi
        if ! ln -s "$src" "$dest"; then
            echo "  ! Failed to create symlink at $dest" >&2
            return 1
        fi
        echo "  ✓ $dest (created)"
    else
        if ! ln -s "$src" "$dest"; then
            echo "  ! Failed to create symlink at $dest" >&2
            return 1
        fi
        echo "  ✓ $dest (created)"
    fi
}

install_aliases() {
    local src="${SCRIPT_DIR}/aliases.zsh"
    local legacy=~/.zsh/oh-my-zsh/custom/aliases.zsh
    src="${src:A}"

    link_file "$src" ~/.zsh/aliases.zsh || return 1

    [[ -e "$legacy" || -L "$legacy" ]] || return 0
    if [[ ! -L "$legacy" ]]; then
        echo "  ! Cannot remove $legacy: existing path is not a symlink" >&2
        return 1
    fi

    local current=$(readlink -f "$legacy" 2>/dev/null || readlink "$legacy")
    if [[ "$current" != "$src" ]]; then
        echo "  ! Cannot remove $legacy: symlink points elsewhere" >&2
        return 1
    fi

    if ! rm -f "$legacy"; then
        echo "  ! Failed to remove obsolete symlink at $legacy" >&2
        return 1
    fi
    echo "  ✓ $legacy (removed obsolete link)"
}

create_gitconfig_local() {
    if [[ -f ~/.gitconfig.old ]]; then
        echo "  → Generating ~/.gitconfig.local from previous .gitconfig"
        {
            echo "# Machine-specific gitconfig - DO NOT COMMIT"
            echo "# Generated from previous .gitconfig during bootstrap setup"
            echo ""
        } > ~/.gitconfig.local || return 1
        git --no-pager config --file ~/.gitconfig.old --get-regexp '^user\.' | while read -r key value; do
            git config --file ~/.gitconfig.local "$key" "$value" || return 1
        done
        git --no-pager config --file ~/.gitconfig.old --get-regexp '^credential\.' | while read -r key value; do
            git config --file ~/.gitconfig.local --add "$key" "$value" || return 1
        done
        echo "  ✓ ~/.gitconfig.local (migrated from backup)"
    else
        echo "  → Creating ~/.gitconfig.local from template (edit with your details)"
        cp "$SCRIPT_DIR/../.gitconfig.local.template" ~/.gitconfig.local
    fi
}

merge_copilot_settings() {
    local src="${1:A}"
    local dest="$2"

    if [[ ! -f "$dest" ]]; then
        if ! cp "$src" "$dest"; then
            echo "  ! Failed to create $dest" >&2
            return 1
        fi
        echo "  ✓ $dest (created)"
        return 0
    fi

    if ! command -v jq >/dev/null 2>&1; then
        echo "  ! Cannot merge $dest: jq is not installed" >&2
        return 1
    fi

    local merged
    merged=$(jq --slurpfile managed "$src" '. + $managed[0]' "$dest") || return 1

    print -r -- "$merged" > "$dest" || return 1
    echo "  ✓ $dest (managed settings applied)"
}

# ------------------------------
# Create ~/.zsh directory
# ------------------------------
if [[ ! -d ~/.zsh ]]; then
    echo "Creating ~/.zsh directory..."
    run_step "Create ~/.zsh directory" mkdir -p ~/.zsh
fi
run_step "Set ~/.zsh permissions" chmod 700 ~/.zsh

# ------------------------------
# Install oh-my-zsh if missing
# ------------------------------
echo "Checking oh-my-zsh..."
if [[ ! -d ~/.zsh/oh-my-zsh ]]; then
    if [[ "$LOCAL_MODE" == true ]]; then
        echo "  ! Skipping oh-my-zsh install (--local mode)"
    else
        echo "  Installing oh-my-zsh..."
        run_step "Install oh-my-zsh" git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git ~/.zsh/oh-my-zsh
    fi
else
    echo "  ✓ Already installed"
fi
if [[ -d ~/.zsh/oh-my-zsh ]]; then
    run_step "Set oh-my-zsh directory permissions" find ~/.zsh/oh-my-zsh -type d -exec chmod 700 {} \;
fi

# ------------------------------
# Install zsh-autosuggestions plugin if missing
# ------------------------------
echo "Checking zsh-autosuggestions..."
if [[ ! -d ~/.zsh/oh-my-zsh/custom/plugins/zsh-autosuggestions ]]; then
    if [[ "$LOCAL_MODE" == true ]]; then
        echo "  ! Skipping zsh-autosuggestions install (--local mode)"
    else
        echo "  Installing zsh-autosuggestions..."
        run_step "Install zsh-autosuggestions" git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/oh-my-zsh/custom/plugins/zsh-autosuggestions
    fi
else
    echo "  ✓ Already installed"
fi

# ------------------------------
# Symlink config files
# ------------------------------
echo "Checking symlinks..."

run_step "Link ~/.zshenv" link_file "$SCRIPT_DIR/.zshenv" ~/.zshenv
run_step "Link ~/.zsh/.zshenv" link_file "$SCRIPT_DIR/.zshenv" ~/.zsh/.zshenv
run_step "Link .zprofile" link_file "$SCRIPT_DIR/.zprofile" ~/.zsh/.zprofile
run_step "Link .zshrc" link_file "$SCRIPT_DIR/.zshrc" ~/.zsh/.zshrc
run_step "Install aliases" install_aliases
run_step "Link vimrc" link_file "$SCRIPT_DIR/../.vimrc" ~/.vimrc
run_step "Link gitconfig" link_file "$SCRIPT_DIR/../.gitconfig" ~/.gitconfig

# Create .gitconfig.local if it doesn't exist
if [[ ! -f ~/.gitconfig.local ]]; then
    run_step "Create ~/.gitconfig.local" create_gitconfig_local
fi

# ------------------------------
# Wire up global git hooks
# ------------------------------
# core.hooksPath needs an absolute filesystem path, which depends on where
# this bootstrap repo was cloned. Writing it to ~/.gitconfig.local (per-machine,
# gitignored) keeps the path out of the shared, committed .gitconfig.
HOOKS_DIR="${SCRIPT_DIR:h}/git/hooks"
if [[ -d "$HOOKS_DIR" ]]; then
    current_hooks_path=$(git config --file ~/.gitconfig.local --get core.hooksPath 2>/dev/null || true)
    if [[ "$current_hooks_path" != "$HOOKS_DIR" ]]; then
        echo "  → Setting core.hooksPath = $HOOKS_DIR in ~/.gitconfig.local"
        if ! git config --file ~/.gitconfig.local core.hooksPath "$HOOKS_DIR"; then
            record_failure "Configure global git hooks"
        fi
    fi
    if [[ "$(git config --file ~/.gitconfig.local --get core.hooksPath 2>/dev/null)" == "$HOOKS_DIR" ]]; then
        echo "  ✓ Global git hooks ($HOOKS_DIR)"
    fi
fi

# ------------------------------
# Copilot CLI setup
# ------------------------------
REPO_ROOT="${SCRIPT_DIR:h}"
DEV_ROOT="${REPO_ROOT:h}"

echo "Checking Copilot CLI setup..."

# Create ~/.copilot if needed
if [[ ! -d ~/.copilot ]]; then
    if mkdir -p ~/.copilot; then
        echo "  Created ~/.copilot/"
    else
        record_failure "Create ~/.copilot directory"
    fi
fi

# Copilot instructions
run_step "Link Copilot instructions" link_file "$REPO_ROOT/ai/copilot-instructions.md" ~/.copilot/copilot-instructions.md

# Copilot settings - managed values win, machine-specific settings are preserved
run_step "Merge Copilot settings" merge_copilot_settings "$REPO_ROOT/ai/copilot-settings.json" ~/.copilot/settings.json

# Memory (diary, reflections) - requires docs repo
if [[ -d "$DEV_ROOT/docs/memory" ]]; then
    run_step "Link Copilot memory" link_file "$DEV_ROOT/docs/memory" ~/.copilot/memory
else
    echo "  ! Skipping memory symlink - docs repo not found at $DEV_ROOT/docs"
fi

# ------------------------------
# Done
# ------------------------------
if (( ${#SETUP_FAILURES[@]} > 0 )); then
    echo ""
    echo "Setup completed with errors:"
    for failure in "${SETUP_FAILURES[@]}"; do
        echo "  - $failure"
    done
    exit 1
fi

echo ""
echo "Setup complete!"
echo "Restart your shell to apply changes."
