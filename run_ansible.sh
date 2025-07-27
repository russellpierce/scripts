#!/usr/bin/env bash

# Abort on error, unset var usage, or pipe failure
set -euo pipefail

PLAYBOOK="./scripts/ansible/setup.yml"

if [[ ! -f "$PLAYBOOK" ]]; then
  echo "Ansible playbook $PLAYBOOK not found." >&2
  exit 1
else
  PLAYBOOK_DIR="$(dirname "$PLAYBOOK")"
  REQS_FILE="$PLAYBOOK_DIR/requirements.yml"

  if [[ -f "$REQS_FILE" ]]; then
    echo "Installing Ansible Galaxy roles defined in $REQS_FILE …"
    ansible-galaxy role install -r "$REQS_FILE"
  fi
fi

# Determine if we need to prompt for sudo password
ASK_BECOME_FLAG=""
if [[ $(id -u) -ne 0 ]]; then
  ASK_BECOME_FLAG="-K"  # ask-become-pass
fi

ansible-playbook $ASK_BECOME_FLAG -i localhost, -c local "$PLAYBOOK"