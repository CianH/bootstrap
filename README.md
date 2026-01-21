# Bootstrap

Personal dotfiles and machine configuration for Windows, macOS, and Linux.

## Setup

### ZSH (macOS, Linux, WSL)

```bash
git clone https://github.com/CianH/bootstrap.git ~/github/bootstrap
~/github/bootstrap/zsh/setup.sh
```

The setup script installs oh-my-zsh, zsh-autosuggestions, and symlinks config files.

### Windows (PowerShell)

```powershell
git clone https://github.com/CianH/bootstrap.git C:\dev\bootstrap
C:\dev\bootstrap\win\scripts\basic_machine_setup.ps1
```

The setup script installs posh-git and symlinks PowerShell profile, Windows Terminal settings, vimrc, and gitconfig.
