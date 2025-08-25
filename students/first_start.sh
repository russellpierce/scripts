#!/bin/bash

echo "Currently running with home directory $HOME"
#export HOME=/home/ec2-user
echo 

# Ensure HOME is set before proceeding with installations
if [ -z "$HOME" ]; then
  export HOME="/home/ec2-user/SageMaker"
  echo "Warning: \$HOME was empty. Set to /home/ec2-user/SageMaker."
fi

echo "Using HOME directory: $HOME"

# Fail on errors, unset variables, or pipe failures
set -euo pipefail

# Targeting Amazon Linux; it enforces a 5 minute timeout on the script

# This will be executed as a Sagemaker Notebook Instance Lifecycle Config Script
# On the first start of the notebook instance, this script will be executed.

# Detect if running as root; if so, set SUDO="" else SUDO="sudo"
if [ "$(id -u)" -eq 0 ]; then
  SUDO=""
else
  SUDO="sudo"
fi

# Ensure curl and unzip are present (Amazon Linux / EC2 Linux)
if ! command -v curl &>/dev/null || ! command -v unzip &>/dev/null; then
  if command -v yum &>/dev/null; then
    ${SUDO} yum install -y curl unzip
  elif command -v dnf &>/dev/null; then
    ${SUDO} dnf install -y curl unzip
  else
    echo "Neither yum nor dnf found. This script is intended for Amazon Linux." >&2
    exit 1
  fi
fi

# Shutdown idle instances after default interval specified in script
curl -O https://raw.githubusercontent.com/aws-samples/amazon-sagemaker-notebook-instance-lifecycle-config-samples/master/scripts/auto-stop-idle/on-start.sh
# Ensure UNIX line endings
sed -i 's/\r$//' on-start.sh
chmod +x on-start.sh
./on-start.sh

# Fetch and unzip russellpierce/scripts public repo from GitHub
curl -L -o scripts.zip https://github.com/russellpierce/scripts/archive/refs/heads/main.zip
unzip -o scripts.zip
rm scripts.zip

# Run the project’s Ansible installation script (honours its own sudo logic).
# ${SUDO} ./scripts/install_ansible.sh

# Non-Ansible Managed Software

# Install uv
uv --version || (curl -LsSf https://astral.sh/uv/install.sh | sh)

# Set up pyenv environment variables before installation

if [ -z "$HOME" ]; then
  export HOME="/home/ec2-user/SageMaker"
  echo "Warning: \$HOME was empty. Set to /home/ec2-user/SageMaker."
fi
export PYENV_ROOT="$HOME/.pyenv"
echo "Installing pyenv to: $PYENV_ROOT"
curl -fsSL https://pyenv.run | bash

echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init - bash)"' >> ~/.bashrc

# Add pyenv to current session PATH
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init - bash)"
# eval "$(pyenv virtualenv-init -)"
# pyenv install 3.10