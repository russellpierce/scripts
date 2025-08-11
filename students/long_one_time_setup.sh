#!/bin/bash
# Targeting Amazon Linux
# assume that first_start.sh has already been run
# Fail on errors, unset variables, or pipe failures
set -euo pipefail

# Decide whether to install Ollama natively or run it in Docker based on GLIBC version
glibc_version=$(getconf GNU_LIBC_VERSION | awk '{print $2}')
required_glibc=2.27

version_lt() {
  # returns 0 (true) if $1 < $2
  [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" != "$2" ]
}

if version_lt "$glibc_version" "$required_glibc"; then
  echo "glibc $glibc_version detected (< $required_glibc). Falling back to Docker-based Ollama install…"

  # Install Docker if it is not already present
  if ! command -v docker >/dev/null 2>&1; then
    if command -v dnf >/dev/null 2>&1; then
      echo "Installing Docker via dnf"
      sudo dnf -y update
      sudo dnf -y install docker
    else
      echo "Installing Docker via yum"
      sudo yum -y update
      sudo yum -y install docker
    fi
    sudo systemctl enable --now docker
  fi

  # Launch the Ollama container (only if not already running)
  if ! sudo docker ps --format '{{.Names}}' | grep -q '^ollama$'; then
    sudo docker run -d --name ollama -p 11434:11434 -v "$HOME/.ollama":/root/.ollama ollama/ollama:latest
  fi

  # Pull required models inside the container
  sudo docker exec ollama ollama pull gemma3n:1b
  sudo docker exec ollama ollama pull llama3.2:1b

  echo "Ollama container setup complete. Access the API at http://localhost:11434/."
else
  echo "glibc $glibc_version (>= $required_glibc). Installing Ollama natively…"

  # Ensure up-to-date core libraries for native installation
  if command -v dnf >/dev/null 2>&1; then
    sudo dnf -y update
    sudo dnf -y install glibc libstdc++ gcc gcc-c++ git curl
  fi

  # Native install of Ollama & models
  curl -fsSL https://ollama.com/install.sh | sh
  ollama pull gemma3n:latest
  ollama pull llama3.2:1b
  ollama serve

  echo "Native Ollama setup complete. The ollama daemon is now available on port 11434."
fi