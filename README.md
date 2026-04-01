# Dotfiles

Personal dotfiles for macOS development environment. Originally forked from [@holman/dotfiles](https://github.com/holman/dotfiles), now restructured for better organization and `~/.config` support.

## Features

- **Topic-based organization** - Configuration grouped by application/tool
- **Per-host configuration** - Different packages for different machines
- **`~/.config` support** - Sync XDG-compliant app configs (Zed, etc.)
- **Dry-run mode** - Preview changes before applying
- **Automatic backups** - Existing files are backed up before replacing

## Quick Start

```sh
git clone https://github.com/lukecartledge/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
script/bootstrap
```

You can clone the repo anywhere; bootstrap will symlink it to `~/.dotfiles`.

## Directory Structure

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
│   └── ...
├── hosts/                  # Per-machine package configuration
│   └── {hostname}.bash     # Defines PACKAGES array for each machine
├── macos/                  # macOS system preferences
├── script/
│   ├── bootstrap           # Initial setup script
│   ├── run                 # Main installation script
│   └── common.bash         # Shared functions
└── Brewfile                # Homebrew packages
```

## How It Works

### Host Configuration

Each machine has a configuration file in `hosts/{hostname}.bash` that defines which packages to install:

```bash
# hosts/My-MacBook-Pro.bash
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

Find your hostname with: `hostname -s`

### Package Structure

Each package in `home/` can contain:

| File | Purpose |
|------|---------|
| `*.zsh` | Shell configuration (auto-sourced by zshrc) |
| `path.zsh` | PATH setup (loaded first) |
| `completion.zsh` | Autocompletion (loaded last) |
| `install.bash` | One-time setup (e.g., prompt for credentials) |
| `link.bash` | Symlink definitions |
| Config files | Actual dotfiles (gitconfig, vimrc, etc.) |

### Link Scripts

Link scripts define where files should be symlinked:

```bash
# home/git/link.bash
link_home "$HOME_DIR/git/gitconfig" "gitconfig"    # → ~/.gitconfig
link_home "$HOME_DIR/git/gitignore" "gitignore"    # → ~/.gitignore
```

For `~/.config` directories:

```bash
# home/zed/link.bash
link "$HOME_DIR/zed/config/settings.json" "$HOME/.config/zed/settings.json"
```

## Commands

### Initial Setup

```sh
script/bootstrap
```

Sets up everything: creates symlinks, installs Homebrew, runs package scripts.

### Update Environment

```sh
dot
```

Pulls latest changes, updates Homebrew, sets macOS defaults, and runs `script/run`.

### Dry Run

Preview what would happen without making changes:

```sh
script/run --dry
# or
dot --dry
```

### Edit Dotfiles

```sh
dot --edit
```

Opens the dotfiles directory in your editor.

## Adding New Packages

1. Create a directory in `home/`:
   ```sh
   mkdir -p home/myapp/config
   ```

2. Add configuration files

3. Create `link.bash`:
   ```bash
   # home/myapp/link.bash
   link_home "$HOME_DIR/myapp/config" "myapprc"
   # or for ~/.config:
   link "$HOME_DIR/myapp/config" "$HOME/.config/myapp"
   ```

4. Add to your host configuration:
   ```bash
   # hosts/{hostname}.bash
   export PACKAGES=(
     ...
     myapp
   )
   ```

5. Run `script/run` to apply

## Adding a New Machine

1. Find your hostname:
   ```sh
   hostname -s
   ```

2. Create host configuration:
   ```sh
   cp hosts/Luke-Cartledge-MacBookPro.bash hosts/{your-hostname}.bash
   ```

3. Edit the packages list for your machine

4. Run bootstrap:
   ```sh
   script/bootstrap
   ```

## Sensitive Data

Files containing API tokens or secrets should use the `.local` pattern:

- `settings.json` - Tracked in git (no secrets)
- `settings.local.json` - Git-ignored (contains tokens)

Example files are provided with `.example` suffix:
```sh
cp home/zed/config/settings.local.json.example home/zed/config/settings.local.json
# Edit and add your tokens
```

## macOS Defaults

System preferences are set via `macos/set-defaults.sh`. These are applied when running `dot` or `script/bootstrap`.

Changes may require logout/restart to take effect.

## Troubleshooting

### "No host configuration found"

Create a host file for your machine:
```sh
hostname -s  # Get your hostname
cp hosts/Luke-Cartledge-MacBookPro.bash hosts/{your-hostname}.bash
```

### Symlink conflicts

Existing files are automatically backed up with a timestamp:
```
~/.gitconfig.backup.20240131120000
```

To restore:
```sh
mv ~/.gitconfig.backup.20240131120000 ~/.gitconfig
```

### Shell not loading changes

Source your zshrc:
```sh
source ~/.zshrc
```

Or restart your terminal.

## License

MIT