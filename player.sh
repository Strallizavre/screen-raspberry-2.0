#!/bin/bash

MODE=$1
SOURCE=$2
EXTRA=$3

VERSION=$(cat /opt/player/version.txt)
MODEL=$(cat /proc/device-tree/model)

OSD="v$VERSION | $MODEL | $MODE"

if [ "$EXTRA" == "OFFLINE" ]; then
    OSD="$OSD | OFFLINE"
fi

BASE_ARGS=(
    --fs
    --no-border
    --really-quiet
    --osd-level=1
    --osd-msg1="$OSD"
    --ao=alsa
    --audio-device=alsa
    --cache=yes
    --cache-secs=10
    --hwdec=auto
)

if [ "$MODE" == "file" ]; then
    exec mpv "${BASE_ARGS[@]}" --loop "$SOURCE"
elif [ "$MODE" == "stream" ]; then
    exec mpv "${BASE_ARGS[@]}" "$SOURCE"
fi