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
    --hwdec=auto-safe
    --profile=low-latency
    --framedrop=vo

    --video-sync=display-resample
    --interpolation=no

    --cache=yes
    --cache-secs=10

    # 🔥 OSD (чистый, без таймера)
    --osd-level=0
    --osd-font-size=18
    --osd-msg1="$OSD"

    # 🔊 звук HDMI
    --audio-device=alsa/default
)

if [ "$MODE" = "file" ]; then
    mpv "${BASE_ARGS[@]}" --loop "$SOURCE"
else
    mpv "${BASE_ARGS[@]}" "$SOURCE"
fi