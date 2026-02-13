#!/bin/bash
python -m ensurepip
if ! grep -qi 'amzn' /etc/os-release; then
  echo "LOCAL" > "/tmp/runtime"
  exit 0
else
  uv --version || (curl -LsSf https://astral.sh/uv/install.sh | sh)
  echo "AWS" > "/tmp/runtime"

  if [ -f pyproject.toml ]; then
    echo "pyproject.toml found. Generating requirements.txt and installing dependencies. This may take a few minutes..."
  else
    echo "pyproject.toml not found. Downloading from https://raw.githubusercontent.com/russellpierce/scripts/refs/heads/main/students/pyproject.toml"
    curl -O https://raw.githubusercontent.com/russellpierce/scripts/refs/heads/main/students/pyproject.toml
    echo "pyproject.toml downloaded. Generating requirements.txt and installing dependencies. This may take a few minutes..."
  fi

  echo "pyproject.toml found. Generating requirements.txt and installing dependencies. This may take a few minutes..."
  /home/ec2-user/.local/bin/uv pip compile pyproject.toml -o requirements.txt --quiet
  pip install -q -r requirements.txt
  
  if ! sudo docker ps --format '{{.Names}}' | grep -q '^ollama$'; then
    sudo docker run -d --name ollama -p 11434:11434 -v "$HOME/.ollama":/root/.ollama ollama/ollama:latest
  fi
  curl -sSL https://raw.githubusercontent.com/russellpierce/scripts/refs/heads/main/students/models.sh | bash -s --
fi
