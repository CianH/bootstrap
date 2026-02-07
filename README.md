# Bootstrap

Personal dotfiles and machine configuration for Windows, macOS, and Linux.

## Setup

All repos should be cloned as siblings under a common dev directory (e.g. `~/dev/` or `C:\dev\`).

```bash
# Clone all repos
git clone https://github.com/CianH/bootstrap.git ~/dev/bootstrap
git clone https://github.com/CianH/docs.git ~/dev/docs
git clone https://github.com/CianH/scripts.git ~/dev/scripts
```

### ZSH (macOS, Linux, WSL)

```bash
~/dev/bootstrap/zsh/setup.sh
```

### Windows (PowerShell)

```powershell
C:\dev\bootstrap\win\scripts\basic_machine_setup.ps1
```

### What the setup scripts do

- Install shell plugins (oh-my-zsh + zsh-autosuggestions / posh-git)
- Symlink shell config, vimrc, and gitconfig
- **Copilot CLI**: symlink instructions and memory into `~/.copilot/`
  - `copilot-instructions.md` → `bootstrap/ai/copilot-instructions.md`
  - `memory/` → `docs/memory/` (diary entries, reflections)

The Copilot CLI sections gracefully skip if the `docs` or `scripts` repos aren't cloned yet.
