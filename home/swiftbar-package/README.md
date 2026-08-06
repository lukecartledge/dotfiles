# SwiftBar Package

This dotfiles package installs the standalone private SwiftBar repository and links its plugins into SwiftBar's macOS plugin directory.

The package directory is deliberately named `swiftbar-package`, not `swiftbar`, so SwiftBar cannot mistake dotfiles metadata for executable plugins if its plugin directory is misconfigured.

The plugin source of truth is `git@github.com:lukecartledge/copilot-quota.git`. By default, the repository is checked out at `$HOME/code/copilot-quota`; override `SWIFTBAR_REPOSITORY` or `SWIFTBAR_CHECKOUT` when running the package scripts manually.

The package does not overwrite an existing checkout or pull updates automatically. Update the standalone repository separately, review local changes, and rerun the dotfiles setup to refresh links.

Run `script/run --dry` to preview package processing. A real run requires authenticated access to the private repository and links plugins into `$HOME/Library/Application Support/SwiftBar/Plugins`.
