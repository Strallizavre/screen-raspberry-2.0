#!/bin/bash

CONFIG="/opt/player/config.json"
STATE="/opt/player/state.json"
MEDIA="/opt/player/media"
VERSION=$(cat /opt/player/version.txt)

log() {
    echo "[AGENT v$VERSION] $1"
}

get_config() {
    cat $CONFIG
}

get_command() {
    API=$(jq -r '.api_url' $CONFIG)
    ID=$(jq -r '.device_id' $CONFIG)
    curl -s "$API/rasp_screen/$ID/command"
}

download_file() {
    URL=$1
    FILE=$2

    if [ -f "$FILE" ]; then
        log "Файл уже есть: $FILE"
        return
    fi

    log "Скачивание $FILE"
    curl -L "$URL" -o "$FILE"
}

start_player() {
    MODE=$1
    SOURCE=$2

    bash /opt/player/player.sh "$MODE" "$SOURCE" &
}

kill_player() {
    pkill -f player.sh
    pkill -f mpv
}

while true; do
    CMD=$(get_command)

    if [ -z "$CMD" ]; then
        log "OFFLINE режим"
        CMD=$(cat $STATE 2>/dev/null)
        OFFLINE=1
    else
        OFFLINE=0
    fi

    TYPE=$(echo $CMD | jq -r '.type')

    CURRENT=$(cat $STATE 2>/dev/null)

    if [ "$CURRENT" = "$CMD" ]; then
        log "Без изменений → не трогаем плеер"
        sleep 60
        continue
    fi

    echo "$CMD" > $STATE

    case $TYPE in

        file)
            FILE=$(echo $CMD | jq -r '.filename')
            URL=$(echo $CMD | jq -r '.url')

            PATH_FILE="$MEDIA/$FILE"

            download_file "$URL" "$PATH_FILE"

            log "Запуск файла: $FILE"
            kill_player
            start_player "file" "$PATH_FILE"
        ;;

        stream)
            URL=$(echo $CMD | jq -r '.url')

            log "Запуск стрима"
            kill_player
            start_player "stream" "$URL"
        ;;

        update)
            log "Обновление (фон)"
            bash /opt/player/updater.sh &
        ;;

        *)
            log "Неизвестная команда"
        ;;

    esac

    sleep 60
done