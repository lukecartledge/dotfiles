# Agent Instructions for @lukecartledge dotfiles

## Repository Overview

This is a **personal dotfiles repository** for managing macOS shell environment, application configurations, and system preferences. The repository uses a **topic-based organization** with **per-host configuration** and **`~/.config` support**.

**Primary Purpose**: Automated setup and synchronization of macOS development environment across multiple machines.

**Key Technologies**: 
- Shell scripting (Bash/Zsh)
- Homebrew package management
- Zsh with Oh-My-Zsh framework
- Powerlevel10k theme
- Symlink-based configuration management

## Critical Architecture Principles

### Directory Structure

```
.dotfiles/
├── bin/                    # Executable utilities (added to $PATH)
│   ├── dot                 # Update script - run periodically
│   ├── host                # Returns current hostname
│   └── ...
├── home/                   # User configuration organized by app
│   ├── git/
│   │   ├── gitconfig       # → ~/.gitconfig
│   │   ├── gitignore       # → ~/.gitignore
│   │   ├── *.zsh           # Shell configuration (auto-sourced)
│   │   ├── install.bash    # Setup script (e.g., prompt for credentials)
│   │   └── link.bash       # Symlink definitions
│   ├── zsh/
│   │   ├── zshrc           # → ~/.zshrc
│   │   └── *.zsh           # Additional shell config
│   ├── zed/
│   │   ├── config/         # → ~/.config/zed/
│   │   └── link.bash
│   └── {package}/          # Other packages follow same pattern
├── hosts/                  # Per-machine package configuration
│   └── {hostname}.bash     # Defines PACKAGES array for each machine
├── macos/                  # macOS system preferences
├── homebrew/               # Homebrew installation
├── script/
│   ├── bootstrap           # Initial setup script
│   ├── run                 # Main installation script
│   └── common.bash         # Shared functions (link, log, backup)
└── Brewfile                # Homebrew packages
```

### Package Structure

Each package in `home/{package}/` can contain:

| File | Purpose |
|------|---------|
| `*.zsh` | Shell configuration (auto-sourced by zshrc) |
| `path.zsh` | PATH setup (loaded first) |
| `completion.zsh` | Autocompletion (loaded last) |
| `install.bash` | One-time setup script |
| `link.bash` | Symlink definitions |
| Config files | Actual dotfiles |

### Host Configuration

Each machine has a config file in `hosts/{hostname}.bash`:

```bash
export SYSTEM="macos"
export PACKAGES=(
  system
  zsh
  git
  vim
  zed
  tmux
  ruby
)
```

The hostname is determined by `bin/host` (runs `hostname -s`).

### Bootstrap Flow

1. **Initial Setup**: `script/bootstrap`
   - Creates `~/.dotfiles` symlink if repo is elsewhere
   - Installs Homebrew (macOS)
   - Installs Brewfile packages
   - Checks for host configuration
   - Runs `script/run`

2. **Updates**: `bin/dot`
   - Pulls latest changes from git
   - Sets macOS defaults
   - Updates Homebrew
   - Runs `script/run`

3. **Package Installation**: `script/run`
   - Sources host configuration
   - For each package in PACKAGES array:
     - Runs `install.bash` if exists
     - Runs `link.bash` if exists

## Build & Validation Commands

### Setup (First Time)
```bash
git clone https://github.com/lukecartledge/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
script/bootstrap
```

### Update Environment
```bash
dot
```

### Dry Run (Preview Changes)
```bash
script/run --dry
# or
dot --dry
```

### Validation Steps

1. **Test scripts without changes**:
   ```bash
   script/run --dry
   ```

2. **After modifying shell files (*.zsh)**:
   ```bash
   source ~/.zshrc
   ```

3. **After modifying Brewfile**:
   ```bash
   brew bundle check
   brew bundle
   ```

4. **Verify host configuration**:
   ```bash
   cat hosts/$(bin/host).bash
   ```

## Key File Locations

### Core Scripts
- `script/bootstrap` - Initial setup script
- `script/run` - Main package installation/linking
- `script/common.bash` - Shared functions (link, link_home, link_config, log, backup)
- `bin/dot` - Update/maintenance script
- `bin/host` - Returns current hostname

### Configuration Files
- `Brewfile` - Homebrew package definitions
- `hosts/{hostname}.bash` - Per-machine package lists
- `home/zsh/zshrc` - Main zsh configuration
- `home/git/gitconfig` - Global git configuration

### Link Script Functions

Available in `link.bash` files (from `script/common.bash`):

```bash
# Link to home directory as dotfile
link_home "$HOME_DIR/git/gitconfig" "gitconfig"   # → ~/.gitconfig

# Link to ~/.config
link_config "$HOME_DIR/zed/config" "zed"          # → ~/.config/zed

# Generic link
link "$source" "$destination"
```

## Important Constraints & Gotchas

### Zsh File Loading Order

Files load in this order (managed by `home/zsh/zshrc`):
1. All `path.zsh` files from `home/*/`
2. All other `*.zsh` files (except path.zsh and completion.zsh)
3. Zsh completion initialization
4. All `completion.zsh` files

### Sensitive Data

- Files with `.local` suffix are gitignored
- Use `*.local.json.example` templates for sensitive configs
- Never commit API tokens or passwords

Gitignored patterns:
- `*.local`
- `*.local.json`
- `home/git/gitconfig.local`
- `home/zed/config/settings.local.json`

### Backup Behavior

When linking, existing files are automatically backed up:
```
~/.gitconfig → ~/.gitconfig.backup.20240131120000
```

### macOS Specific

- `macos/set-defaults.sh` modifies system preferences
- Changes may require logout/restart
- `bin/dot` only runs macOS-specific commands on Darwin

### Dependencies

The repository assumes:
- **macOS** (Darwin)
- **Homebrew** installed or installable
- **Zsh** as shell
- **Oh-My-Zsh** installed at `~/.oh-my-zsh`
- External tools: `mise`, `zoxide`, `fzf`, `broot` (optional, checked before sourcing)

## Common Modification Patterns

### Adding a New Package

1. Create directory: `mkdir -p home/newpackage`
2. Add configuration files
3. Create `link.bash`:
   ```bash
   link_home "$HOME_DIR/newpackage/config" "newpackagerc"
   ```
4. Add to host configuration in `hosts/{hostname}.bash`
5. Run `script/run`

### Adding ~/.config Support

```bash
# home/newapp/link.bash
mkdir -p "$HOME/.config/newapp"
link "$HOME_DIR/newapp/config/settings.json" "$HOME/.config/newapp/settings.json"
```

### Adding a New Machine

1. Get hostname: `hostname -s`
2. Create: `hosts/{hostname}.bash`
3. Define PACKAGES array
4. Run: `script/bootstrap`

### Modifying Shell Configuration

1. Edit files in `home/{package}/*.zsh`
2. Source to test: `source ~/.zshrc`
3. Commit changes

## Trust These Instructions

This file documents the current architecture. **Trust these instructions** and only perform additional searches if information is incomplete or found to be incorrect. The repository has no CI/CD or test suite - validation is manual via dry-run and shell sourcing.
