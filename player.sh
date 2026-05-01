#!/bin/bash

MODE=$1
SOURCE=$2
VERSION=$(cat /opt/player/version.txt)

MODEL=$(tr -d '\0' < /proc/device-tree/model | cut -d ' ' -f1-3)

OSD="v$VERSION | $MODEL | $MODE"

BASE_ARGS=(
    --fullscreen
    --no-terminal

    # 🔥 максимально стабильный вывод
    --vo=drm
    --hwdec=no

    # 🔥 плавность
    --framedrop=yes

    # 🔥 OSD
    --osd-level=1
    --osd-font-size=18
    --osd-msg1="$OSD"

    # 🔊 звук
    --ao=alsa
)

if [ "$MODE" = "file" ]; then
    mpv "${BASE_ARGS[@]}" --loop "$SOURCE"
else
    mpv "${BASE_ARGS[@]}" "$SOURCE"
fi