#!/usr/bin/env bash
# Shared environment detection helpers used by install scripts.
set -euo pipefail

# Ensure required commands are present
require_commands() {
  local missing=0
  for cmd in "$@"; do
    if ! command -v "$cmd" &>/dev/null; then
      echo "Required command '$cmd' not found." >&2
      missing=1
    fi
  done
  if [[ "$missing" -ne 0 ]]; then
    exit 1
  fi
}

# Detect the system's package manager and architecture.
# Exports: PKG_MANAGER, ARCH, ASSET_EXT
detect_os_arch() {
  if command -v apt-get &>/dev/null; then
    PKG_MANAGER="apt-get"
    ARCH=$(dpkg --print-architecture)
    ASSET_EXT="deb"
  elif command -v dnf &>/dev/null; then
    PKG_MANAGER="dnf"
    ARCH=$(uname -m)
    ASSET_EXT="rpm"
  elif command -v yum &>/dev/null; then
    PKG_MANAGER="yum"
    ARCH=$(uname -m)
    ASSET_EXT="rpm"
  else
    echo "Unsupported Linux distribution – apt-get, dnf, or yum not found." >&2
    return 1
  fi

  export PKG_MANAGER ARCH ASSET_EXT
}

# Determine whether to prefix commands with sudo.
# Exports: SUDO
detect_sudo() {
  if [ "$(id -u)" -eq 0 ]; then
    SUDO=""
  else
    if command -v sudo &>/dev/null; then
      SUDO="sudo"
    else
      echo "This script requires root privileges or sudo but sudo is not installed." >&2
      exit 1
    fi
  fi

  export SUDO
} 