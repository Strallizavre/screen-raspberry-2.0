#!/bin/bash

URL=$1

cd /opt/player || exit 1

if [ -n "$URL" ]; then
    TMP="/tmp/update.tar.gz"

    echo "[UPDATER] download: $URL"

    if curl -L "$URL" -o "$TMP"; then
        echo "[UPDATER] extract"
        tar -xzf "$TMP" -C /opt/player
    else
        echo "[UPDATER] download failed → fallback to git"
        git fetch --all
        git reset --hard origin/main
    fi
else
    echo "[UPDATER] no URL → git pull"
    git fetch --all
    git reset --hard origin/main
fi

chmod +x /opt/player/*.sh

systemctl restart player

echo "[UPDATER] done"