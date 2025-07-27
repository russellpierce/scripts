#!/bin/bash

uv --version || (curl -LsSf https://astral.sh/uv/install.sh | sh)

cursor --version || (
   # In your WSL2 terminal
   curl -fsSL https://download.cursor.sh/linux/debian/public.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cursor.gpg
   echo "deb [signed-by=/usr/share/keyrings/cursor.gpg] https://download.cursor.sh/linux/debian stable main" | sudo tee /etc/apt/sources.list.d/cursor.list
   sudo apt update
   sudo apt install cursor
)

sudo apt-get update 
sudo apt-get install -y build-essential cmake htop

curl -L -o scripts.zip https://github.com/russellpierce/scripts/archive/refs/heads/main.zip
unzip -o scripts.zip
rm scripts.zip
./scripts/install_ansible.sh
./scripts/run_ansible.sh