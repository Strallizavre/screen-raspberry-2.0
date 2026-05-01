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

    # 🔥 КРИТИЧНО для Pi (убирает лаги)
    --vo=gpu
    --gpu-context=drm
    --hwdec=auto

    # 🔥 стабильность
    --framedrop=yes
    --video-sync=audio

    # 🔥 убираем лишнюю нагрузку
    --interpolation=no

    # 🔥 кэш (умеренный)
    --cache=yes
    --cache-secs=5

    # 🔥 OSD (фикс)
    --osd-level=1
    --osd-font-size=18
    --osd-msg1="$OSD"

    # 🔊 HDMI звук
    --ao=alsa
)

if [ "$MODE" = "file" ]; then
    mpv "${BASE_ARGS[@]}" --loop "$SOURCE"
else
    mpv "${BASE_ARGS[@]}" "$SOURCE"
fi