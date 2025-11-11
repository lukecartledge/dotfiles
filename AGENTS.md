# Agent Instructions for @lukecartledge dotfiles

## Repository Overview

This is a **personal dotfiles repository** (forked from @holman/dotfiles) for managing macOS shell environment, application configurations, and system preferences. The repository is **~2.7MB** with **~462 files** organized into topic-based directories.

**Primary Purpose**: Automated setup and synchronization of macOS development environment including zsh configuration, git settings, Homebrew packages, and system preferences.

**Key Technologies**: 
- Shell scripting (Bash/Zsh)
- Homebrew package management
- Zsh with Oh-My-Zsh framework
- Powerlevel10k theme
- Symlink-based configuration management

## Critical Architecture Principles

### Topic-Based Organization
Files are organized by topic (git, ruby, zsh, etc.). Each topic directory can contain:
- `*.zsh` - Auto-loaded into shell environment
- `path.zsh` - Loaded FIRST to setup PATH
- `completion.zsh` - Loaded LAST for autocomplete
- `*.symlink` - Symlinked to `$HOME` without extension during bootstrap
- `install.sh` - Executed during `script/install` (NOT auto-loaded)

### Bootstrap Flow
The repository uses a specific initialization sequence that MUST be followed:

1. **Initial Setup**: `script/bootstrap` (one-time setup)
   - Creates `git/gitconfig.local.symlink` if missing (prompts for git author name/email)
   - Symlinks all `*.symlink` files to `$HOME/.{basename}`
   - On macOS: runs `bin/dot` to install dependencies

2. **Updates**: `bin/dot` (run periodically)
   - Pulls latest changes from git
   - Sets macOS defaults via `macos/set-defaults.sh`
   - Fixes macOS hostname issues via `macos/set-hostname.sh`
   - Installs/updates Homebrew
   - Runs `script/install`

3. **Package Installation**: `script/install`
   - Runs `brew bundle` to install Brewfile packages
   - Executes all topic-level `install.sh` scripts

## Build & Validation Commands

### Setup (First Time)
```bash
# Clone repository (if not already cloned)
git clone https://github.com/lukecartledge/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Run bootstrap - ALWAYS do this for initial setup
script/bootstrap
# This will:
# - Prompt for git author name and email (required)
# - Symlink configuration files to home directory
# - Install Homebrew dependencies on macOS
```

### Update Environment
```bash
# From anywhere (bin/dot is in PATH after bootstrap)
dot

# Or explicitly from dotfiles directory
cd ~/.dotfiles
bin/dot
```

### Install/Update Packages
```bash
cd ~/.dotfiles

# Install Homebrew packages from Brewfile
brew bundle

# Run all topic install scripts
script/install
```

### Validation Steps
**No formal test suite exists.** Validate changes manually:

1. **After modifying shell files (*.zsh)**:
   ```bash
   # Source zshrc to test for syntax errors
   source ~/.zshrc
   ```

2. **After modifying symlink files (*.symlink)**:
   ```bash
   # Re-run bootstrap to update symlinks
   cd ~/.dotfiles
   script/bootstrap
   ```

3. **After modifying Brewfile**:
   ```bash
   # Validate Brewfile syntax
   brew bundle check
   
   # Install new packages
   brew bundle
   ```

4. **After modifying bin/ scripts**:
   ```bash
   # Verify script is executable
   ls -l ~/.dotfiles/bin/SCRIPT_NAME
   
   # Test script execution
   SCRIPT_NAME --help  # or appropriate test
   ```

## Key File Locations

### Core Setup Scripts
- `script/bootstrap` - Initial setup script (156 lines)
- `script/install` - Package installation script (13 lines)
- `bin/dot` - Update/maintenance script (65 lines)

### Configuration Files
- `Brewfile` - Homebrew package definitions (casks & formulae)
- `git/gitconfig.symlink` - Global git configuration
- `git/gitconfig.local.symlink` - Local git config (gitignored, auto-generated)
- `git/gitconfig.local.symlink.example` - Template for local git config
- `zsh/zshrc.symlink` - Main zsh configuration file
- `zsh/oh-my-zsh.zsh` - Oh-My-Zsh plugin configuration
- `zsh/p10k.zsh` - Powerlevel10k theme configuration

### System Configuration
- `macos/set-defaults.sh` - macOS system preferences (Finder, Safari, dock, etc.)
- `macos/set-hostname.sh` - Fixes macOS hostname numbering issue
- `homebrew/install.sh` - Homebrew installation script
- `system/_path.zsh` - Main PATH configuration
- `editors/env.zsh` - Sets EDITOR='zed'

### Utilities
- `bin/` - 24 executable utilities added to PATH (git helpers, system tools)
- `functions/` - Zsh completion functions and utilities

## Important Constraints & Gotchas

### File Processing Order
Zsh files load in this exact order (managed by `zsh/zshrc.symlink`):
1. All `path.zsh` files
2. All other `*.zsh` files (except path.zsh and completion.zsh)
3. Zsh completion initialization
4. All `completion.zsh` files

**Always follow this order** when adding new zsh configuration.

### Symlink Management
- `script/bootstrap` prompts for action on existing files: [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all
- Symlinks are created from `.dotfiles/topic/*.symlink` to `$HOME/.{basename}`
- Example: `git/gitconfig.symlink` → `~/.gitconfig`

### Git Configuration
- `git/gitconfig.local.symlink` is gitignored and auto-generated
- Contains user-specific settings (name, email, credential helper)
- Created by `script/bootstrap` from `git/gitconfig.local.symlink.example` template
- **Never commit** `git/gitconfig.local.symlink`

### macOS Specific Behavior
- Bootstrap automatically runs `bin/dot` on macOS (Darwin)
- `macos/set-defaults.sh` modifies system preferences via `defaults write`
- Changes may require logout/restart to take effect
- Hostname fix in `macos/set-hostname.sh` requires sudo (TouchID prompt)

### Dependencies
The repository assumes:
- **macOS** (Darwin) - scripts check `uname -s`
- **Homebrew** installed or installable
- **Zsh** as shell
- **Oh-My-Zsh** installed at `~/.oh-my-zsh`
- External tools: `mise`, `zoxide`, `fzf`, `broot` (initialized in zshrc)

### Hidden Dependencies in zshrc.symlink
The main zshrc file sources these external tools (must be installed separately):
```bash
eval "$(mise activate zsh)"        # Runtime version manager
source ~/.config/broot/launcher/zsh/br  # File navigator
eval "$(zoxide init zsh)"          # Smart cd replacement
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh  # Fuzzy finder
```

## Common Modification Patterns

### Adding a New Topic
1. Create directory: `mkdir .dotfiles/newtopic`
2. Add configuration files with appropriate extensions
3. Run `script/bootstrap` to symlink any `*.symlink` files
4. Source `~/.zshrc` to load `*.zsh` files

### Adding Homebrew Packages
1. Edit `Brewfile`
2. Add `brew 'package-name'` or `cask 'app-name'`
3. Run `brew bundle` from `.dotfiles` directory
4. Commit changes to `Brewfile`
5. **Do NOT commit** `Brewfile.lock.json` (gitignored)

### Adding Shell Utilities
1. Add executable script to `bin/` directory
2. Make executable: `chmod +x bin/script-name`
3. Script automatically available in PATH after shell reload

### Modifying System Preferences
1. Edit `macos/set-defaults.sh`
2. Use `defaults write` commands for preferences
3. Run `bin/dot` or execute script directly
4. May require logout/restart to see changes

## Directory Structure Reference

```
.dotfiles/
├── bin/              # 24 executable utilities (auto-added to PATH)
├── editors/          # Editor configuration (env.zsh sets EDITOR)
├── functions/        # Zsh completion functions
├── git/              # Git configuration and aliases
├── homebrew/         # Homebrew setup scripts
├── macos/            # macOS system preference scripts
├── ruby/             # Ruby/gem configuration and aliases
├── script/           # Setup and installation scripts
├── system/           # System-wide PATH and aliases
├── tmux/             # tmux configuration
├── vim/              # vim configuration
├── yarn/             # Yarn configuration (commented out)
├── zsh/              # Zsh configuration (20 .zsh files)
├── Brewfile          # Homebrew package definitions
├── README.md         # User documentation
└── LICENSE.md        # MIT License
```

## Trust These Instructions

This file has been thoroughly validated by exploring the codebase. **Trust these instructions** and only perform additional searches if information is incomplete or found to be incorrect. The repository has no CI/CD, no test suite, and no linting - validation is manual via shell sourcing and script execution.