#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

PROCESS_USER="abc"
PROCESS_GROUP="abc"
APP_DIR="/app"

PUID="${PUID:-1000}"
PGID="${PGID:-1000}"

ALSA_SCONTROL="${ALSA_SCONTROL:-Master}"
ALSA_DEVICE="${ALSA_DEVICE:-default}"
ALSA_PORTS="${ALSA_PORTS:-PCM}"

VLC_PORT="${VLC_PORT:-4212}"
VLC_PASSWORD="${VLC_PASSWORD:-password}"

echo "*** Configuring container ***"

if [ ! -e "$APP_DIR/.configured" ]; then
    echo "*** Configuring user/group: ${PROCESS_USER}:${PROCESS_GROUP} (${PUID}:${PGID}) ***"
    addgroup -g "$PGID" "$PROCESS_GROUP"
    adduser -u "$PUID" -h "$APP_DIR" -g '' -G "$PROCESS_GROUP" -D -H "$PROCESS_USER"

    addgroup -g "$(stat -c %g /dev/snd/timer)" -S alsa
    adduser "$PROCESS_USER" alsa

    mkdir -p "$APP_DIR"
fi

chown -R "$PUID:$PGID" "$APP_DIR"
touch "$APP_DIR/.configured"

echo "*** Configuring XDG environment ***"
export XDG_CACHE_DIR="/tmp/cache"
export XDG_CONFIG_DIR="$APP_DIR/config"
export XDG_DATA_DIR="$APP_DIR/data"
mkdir -p "$XDG_CACHE_DIR" "$XDG_CONFIG_DIR" "$XDG_DATA_DIR"

echo "*** Configuring ALSA ***"
if [[ -n "$ALSA_DEVICE" && -n "$ALSA_SCONTROL" ]]; then
    amixer -q -D "$ALSA_DEVICE" sset "$ALSA_SCONTROL" 100%
    amixer -q -D "$ALSA_DEVICE" sset "$ALSA_SCONTROL" unmute
fi

if [[ -n "$ALSA_DEVICE" && "$ALSA_PORTS" ]]; then
    for PORT in $(echo "$ALSA_PORTS" | tr , " "); do
        amixer -q -D "$ALSA_DEVICE" sset "$PORT" 100%
        amixer -q -D "$ALSA_DEVICE" sset "$PORT" unmute
    done
fi

echo "*** Starting VLC ***"
exec sudo --set-home \
    --preserve-env=XDG_CACHE_DIR,XDG_CONFIG_DIR,XDG_DATA_DIR \
    --user "$PROCESS_USER" \
    vlc -vvvv \
    --no-dbus \
    -A alsa --alsa-audio-device "$ALSA_DEVICE" \
    -I telnet --telnet-host="127.0.0.1" --telnet-port "$VLC_PORT" --telnet-password "$VLC_PASSWORD"
