#!/usr/bin/env bash
#
# smb/install.bash - Deploy /etc/nsmb.conf for SMB multichannel disable
#
# WHY: macOS Tahoe 26.5.x has a bug where SMB multichannel triggers a
# smbfs.kext <-> Wi-Fi driver hang under sustained load on Apple Silicon.
# Disabling multichannel (mc_on=no) routes around it. Without this fix,
# bulk SMB transfers (~5 GB+) freeze the system network stack within ~60s
# and require a Wi-Fi toggle to recover.
#
# Diagnosis: ~/notes/brain/20-work/sessions/2026/06/2026-06-12-wifi-smb-tahoe-bug-dead-end.md
#
# /etc/nsmb.conf is root-owned, so we COPY (not symlink) via sudo. A symlink
# from /etc into a user-writable dotfiles path is a security smell and
# wouldn't survive macOS updates that touch /etc.

if [[ "$(uname -s)" != "Darwin" ]]; then
  return 0
fi

SMB_SRC="$HOME_DIR/smb/nsmb.conf"
SMB_DST="/etc/nsmb.conf"

if [[ ! -f "$SMB_SRC" ]]; then
  fail "Source missing: $SMB_SRC"
  return 1
fi

# Idempotency: if dest matches source byte-for-byte, do nothing
if [[ -f "$SMB_DST" ]] && cmp -s "$SMB_SRC" "$SMB_DST" 2>/dev/null; then
  success "$SMB_DST already up to date"
  return 0
fi

if [[ $dry == "1" ]]; then
  log "Would install $SMB_SRC -> $SMB_DST (via sudo)"
  return 0
fi

info "Deploying $SMB_DST (will prompt for sudo)..."

# Back up existing /etc/nsmb.conf if it differs from our source
if [[ -f "$SMB_DST" ]]; then
  smb_ts=$(date +%Y%m%d%H%M%S)
  if sudo cp "$SMB_DST" "${SMB_DST}.backup.${smb_ts}"; then
    success "Backed up existing $SMB_DST -> ${SMB_DST}.backup.${smb_ts}"
  else
    fail "Failed to back up $SMB_DST"
    return 1
  fi
fi

if sudo install -m 644 -o root -g wheel "$SMB_SRC" "$SMB_DST"; then
  success "Installed $SMB_DST"
  info "If SMB shares are mounted, unmount and remount for changes to take effect"
else
  fail "Failed to install $SMB_DST"
  return 1
fi
