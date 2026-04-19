#!/bin/bash

URL=$1
TMP="/tmp/update.tar.gz"

echo "[UPDATER] Скачивание обновления"
curl -L "$URL" -o "$TMP"

echo "[UPDATER] Распаковка"
tar -xzf "$TMP" -C /opt/player

echo "[UPDATER] Готово"