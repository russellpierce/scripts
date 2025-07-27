#!/bin/bash

# This will be executed as a Sagemaker Notebook Instance Lifecycle Config Script
# On the first start of the notebook instance, this script will be executed.

# Install uv
uv --version || (curl -LsSf https://astral.sh/uv/install.sh | sh)
# uv python install 3.10.4
curl -fsSL https://ollama.com/install.sh | sh
ollama get gemma3n:latest
ollama get llama3.2:1b

sudo apt-get install -y build-essential cmake htop

wget https://raw.githubusercontent.com/aws-samples/amazon-sagemaker-notebook-instance-lifecycle-config-samples/master/scripts/auto-stop-idle/autostop.py
wget https://raw.githubusercontent.com/aws-samples/amazon-sagemaker-notebook-instance-lifecycle-config-samples/master/scripts/auto-stop-idle/on-start.sh

chmod +x on-start.sh
chmod +x autostop.py

# add to crontab
# crontab -e
# @reboot /home/ec2-user/on-start.sh

# Install latest pandoc
bash "$(dirname "$0")/install_pandoc.sh"


