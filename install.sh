#!/bin/bash

echo "Installing player..."

sudo apt update
sudo apt install -y mpv jq curl

sudo mkdir -p /opt/player/media

sudo cp -r ./* /opt/player/

sudo chmod +x /opt/player/*.sh

sudo cp player.service /etc/systemd/system/

sudo systemctl daemon-reexec
sudo systemctl daemon-reload

sudo systemctl enable player
sudo systemctl restart player

echo "Done!"