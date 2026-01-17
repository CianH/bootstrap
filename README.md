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

Symlink the PowerShell directory to your Documents folder:

```powershell
New-Item -ItemType SymbolicLink -Path "$HOME\Documents\PowerShell" -Target "C:\path\to\bootstrap\win\powershell"
```
