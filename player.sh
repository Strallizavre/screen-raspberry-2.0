#!/bin/bash

MODE=$1
SOURCE=$2
VERSION=$(cat /opt/player/version.txt)

MODEL=$(tr -d '\0' < /proc/device-tree/model | cut -d ' ' -f1-3)

OSD="v$VERSION | $MODEL | $MODE"

BASE_ARGS=(
    --fullscreen
    --no-terminal
    --quiet

    # 🔥 плавность
    --hwdec=auto
    --vd-lavc-threads=2
    --cache=yes
    --cache-secs=20

    # 🔥 OSD
    --osd-level=3
    --osd-font-size=18
    --osd-msg1="$OSD"

    # 🔥 звук HDMI
    --audio-device=alsa/default
)

if [ "$MODE" = "file" ]; then
    mpv "${BASE_ARGS[@]}" --loop "$SOURCE"
else
    mpv "${BASE_ARGS[@]}" "$SOURCE"
fi