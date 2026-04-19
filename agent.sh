#!/bin/bash

CONFIG="/opt/player/config.json"
STATE="/opt/player/state.json"
LAST="/opt/player/last_command.json"
MEDIA="/opt/player/media"
VERSION=$(cat /opt/player/version.txt)

PLAYER_PID_FILE="/tmp/player.pid"

log() {
    echo "[AGENT v$VERSION] $1"
}

get_config() {
    API=$(jq -r .api_url $CONFIG)
    DEVICE=$(jq -r .device_id $CONFIG)
    INTERVAL=$(jq -r .poll_interval $CONFIG)
}

save_state() {
    echo "$1" > $STATE
}

kill_player() {
    if [ -f $PLAYER_PID_FILE ]; then
        kill -9 $(cat $PLAYER_PID_FILE) 2>/dev/null
        rm -f $PLAYER_PID_FILE
    fi
}

start_player() {
    /opt/player/player.sh "$@" &
    echo $! > $PLAYER_PID_FILE
}

is_player_alive() {
    if [ -f $PLAYER_PID_FILE ]; then
        kill -0 $(cat $PLAYER_PID_FILE) 2>/dev/null
        return $?
    fi
    return 1
}

download_file() {
    URL=$1
    FILE=$2

    if [ ! -f "$FILE" ]; then
        log "Скачивание $FILE"
        curl -L --fail "$URL" -o "$FILE"
    fi
}

start_stream_with_watchdog() {
    URL=$1

    while true; do
        log "Старт стрима"
        /opt/player/player.sh stream "$URL" &
        PID=$!

        wait $PID

        log "Стрим упал → fallback"
        play_fallback "stream lost"

        sleep 5
    done
}

play_fallback() {
    FILE="$MEDIA/fallback.mp4"
    log "FALLBACK: $1"

    if [ -f "$FILE" ]; then
        kill_player
        start_player file "$FILE" "OFFLINE"
        save_state '{"mode":"fallback"}'
    fi
}

main() {
    get_config

    while true; do

        ONLINE=true
        CMD=$(curl -s --max-time 10 "$API/rasp_screen/$DEVICE/command")

        if [ $? -ne 0 ] || [ -z "$CMD" ]; then
            ONLINE=false
            log "Сервер недоступен → OFFLINE"
        else
            echo "$CMD" > $LAST
        fi

        if [ "$ONLINE" = false ]; then
            if [ -f "$LAST" ]; then
                CMD=$(cat $LAST)
            else
                play_fallback "no internet + no cache"
                sleep 60
                continue
            fi
        fi

        TYPE=$(echo $CMD | jq -r .type)

        log "Команда: $TYPE (online=$ONLINE)"

        case $TYPE in

            file)
                URL=$(echo $CMD | jq -r .url)
                NAME=$(echo $CMD | jq -r .filename)

                FILE="$MEDIA/$NAME"
                download_file "$URL" "$FILE"

                kill_player
                if [ "$ONLINE" = true ]; then
                    start_player file "$FILE"
                else
                    start_player file "$FILE" "OFFLINE"
                fi

                save_state "{\"mode\":\"file\",\"file\":\"$NAME\"}"
                ;;

            stream)
                URL=$(echo $CMD | jq -r .url)

                kill_player

                if [ "$ONLINE" = true ]; then
                    start_stream_with_watchdog "$URL" &
                    echo $! > $PLAYER_PID_FILE
                else
                    play_fallback "offline stream"
                fi

                save_state "{\"mode\":\"stream\"}"
                ;;

            update)
                log "Обновление"
                bash /opt/player/updater.sh &
                ;;

            *)
                log "Неизвестная команда"
                ;;
        esac

        sleep $INTERVAL
    done
}

main