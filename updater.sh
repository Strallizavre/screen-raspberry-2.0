#!/bin/bash

BASE_DIR="/opt/player"
ARCHIVE="/tmp/update.tar.gz"

echo "[UPDATER] Downloading..."

wget -O $ARCHIVE "$1"

echo "[UPDATER] Extracting..."

tar -xzf $ARCHIVE -C $BASE_DIR

rm $ARCHIVE

echo "[UPDATER] Restarting..."

systemctl restart player