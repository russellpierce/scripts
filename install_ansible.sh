#!/usr/bin/env bash
# install_ansible.sh - Install Ansible for major Linux distributions.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/environment_detection.sh"

require_commands sudo curl grep

# Skip installation if Ansible already present
if command -v ansible &>/dev/null; then
  echo "Ansible is already installed: $(ansible --version | head -n1)"
  exit 0
fi

detect_os_arch

case "$PKG_MANAGER" in
  apt-get)
    sudo apt-get update -y
    sudo apt-get install -y software-properties-common
    sudo add-apt-repository --yes --update ppa:ansible/ansible
    sudo apt-get install -y ansible
    ;;
  dnf|yum)
    sudo "$PKG_MANAGER" install -y ansible
    ;;
  *)
    echo "Unsupported package manager: $PKG_MANAGER" >&2
    exit 1
    ;;
esac

echo "Ansible installation complete." 