#!/bin/bash
# Targeting Amazon Linux
# assume that first_start.sh has already been run
# Fail on errors, unset variables, or pipe failures
set -euo pipefail

# Update package list
sudo yum update -y

# Install required development libraries
sudo yum groupinstall -y "Development Tools"
sudo yum install -y --skip-broken \
    bzip2-devel \
    ncurses-devel \
    readline-devel \
    sqlite-devel \
    openssl-devel \
    libffi-devel \
    xz-devel \
    zlib-devel \
    gdbm-devel \
    nss-devel \
    tk-devel \
    tcl-devel \
    libX11-devel \
    libXext-devel \
    libXrender-devel \
    libXinerama-devel \
    libXi-devel \
    libXrandr-devel \
    libXcursor-devel \
    libXcomposite-devel \
    libXdamage-devel \
    libXfixes-devel \
    libXss-devel \
    libXtst-devel \
    alsa-lib-devel \
    pango-devel \
    cairo-devel \
    atk-devel \
    gtk3-devel \
    gdk-pixbuf2-devel \
    gobject-introspection-devel \
    glib2-devel \
    db4-devel \
    libuuid-devel

## Install pyenv
curl -fsSL https://pyenv.run | bash

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - bash)"

# Restart your shell for the changes to take effect.

# Load pyenv-virtualenv automatically by adding
# the following to ~/.bashrc:

eval "$(pyenv virtualenv-init -)"

pyenv install 3.10

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
    sudo docker run --restart always -d --name ollama -p 11434:11434 -v "$HOME/.ollama":/root/.ollama ollama/ollama:latest
  fi

  # Pull required models inside the container
  curl -sSL https://raw.githubusercontent.com/russellpierce/ITAI4350/main/scripts/students/models.sh | bash -s --

  echo "Ollama container setup complete. Access the API at http://localhost:11434/."
else
  echo "glibc $glibc_version (>= $required_glibc). Installing Ollama natively…"

  # Ensure up-to-date core libraries for native installation
  if command -v dnf >/dev/null 2>&1; then
    sudo dnf -y update
    sudo dnf -y install glibc libstdc++ gcc gcc-c++ git curl
    curl -fsSL https://ollama.com/install.sh | sh
  fi

  # Native install of Ollama & models, unavailable on Sagemaker's Amazon Linux
  echo "Native Ollama setup complete. The ollama daemon is now available on port 11434."
fi

curl -sSL https://raw.githubusercontent.com/russellpierce/ITAI4350/main/scripts/students/models.sh | bash -s --