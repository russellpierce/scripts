#!/bin/bash
python -m ensurepip
if ! grep -qi 'amzn' /etc/os-release; then
  echo "LOCAL" > "/tmp/runtime"
  exit 0
else
  uv --version || (curl -LsSf https://astral.sh/uv/install.sh | sh)
  echo "AWS" > "/tmp/runtime"
  # Generate requirements.txt from pyproject.toml using uv
  /home/ec2-user/.local/bin/uv pip compile pyproject.toml -o requirements.txt --quiet
  # Then install normally
  pip install -q -r requirements.txt
  if ! sudo docker ps --format '{{.Names}}' | grep -q '^ollama$'; then
    sudo docker run -d --name ollama -p 11434:11434 -v "$HOME/.ollama":/root/.ollama ollama/ollama:latest
  fi
  curl -sSL https://raw.githubusercontent.com/russellpierce/ITAI4350/main/scripts/students/models.sh | bash -s --
fi

