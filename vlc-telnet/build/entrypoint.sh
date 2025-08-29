#!/bin/bash

set -euo pipefail
IFS=$'\n\t'


PUID="${PUID:-1000}"
PGID="${PGID:-1000}"

ALSA_SCONTROL="${ALSA_SCONTROL:-Master}"
ALSA_DEVICE="${ALSA_DEVICE:-default}"
ALSA_PORT="${ALSA_PORT:-PCM}"
ALSA_PORTS="${ALSA_PORTS:-$ALSA_PORT}"
ALSA_CONFIGURATION="${ALSA_CONFIGURATION:-yes}"

VLC_USER="abc"
VLC_GROUP="abc"
APP_DIR="/app"
VLC_HOST="${VLC_HOST:-127.0.0.1}"
VLC_PORT="${VLC_PORT:-4212}"
VLC_PASSWORD="${VLC_PASSWORD:-password}"

#
# Check for sound devices
#
[[ -c "/dev/snd/timer" ]] || {
    echo "/dev/snd/timer is missing, is /dev/snd binded from host?" >&2
    exit 1
}

echo "*** Configuring container ***"

#
# Create user, group and some additional files and folders
#
if [[ ! -e "$APP_DIR/.configured" ]]; then
    echo "*** Configuring user/group: ${VLC_USER}:${VLC_GROUP} (${PUID}:${PGID}) ***"
    addgroup -g "$PGID" "$VLC_GROUP"
    adduser -u "$PUID" -h "$APP_DIR" -g '' -G "$VLC_GROUP" -D -H "$VLC_USER"

    addgroup -g "$(stat -c %g /dev/snd/timer)" -S alsa
    adduser "$VLC_USER" alsa

    mkdir -p "$APP_DIR"
fi

chown -R "$PUID:$PGID" "$APP_DIR"
touch "$APP_DIR/.configured"

echo "*** Configuring XDG environment ***"
export XDG_CACHE_DIR="/tmp/cache"
export XDG_CONFIG_DIR="$APP_DIR/config"
export XDG_DATA_DIR="$APP_DIR/data"
mkdir -p "$XDG_CACHE_DIR" "$XDG_CONFIG_DIR" "$XDG_DATA_DIR"

if [[
    "$ALSA_CONFIGURATION" = "true" ||
    "$ALSA_CONFIGURATION" = "y" ||
    "$ALSA_CONFIGURATION" = "yes" ||
    "$ALSA_CONFIGURATION" = "1" ]]; then

    echo "*** Configuring ALSA (ALSA_DEVICE='$ALSA_DEVICE', ALSA_PORTS='$ALSA_PORTS') ***"

    #for PORT in "$ALSA_SCONTROL" $(echo "$ALSA_PORTS" | tr , " "); do
    for PORT in $(echo "$ALSA_PORTS" | tr , " "); do
        [[ -n "$PORT" ]] || continue
        amixer -q -D "$ALSA_DEVICE" sset "$PORT" 100% || {
            echo "amixer sset $PORT 100% failed, ignoring"
            true
        }
        amixer -q -D "$ALSA_DEVICE" sset "$PORT" unmute || {
            echo "amixer sset $PORT 100% unmute, ignoring"
            true
        }
    done

else
    echo "*** Skip ALSA configuration"
fi

echo "*** Starting VLC ***"
exec sudo --set-home \
    --preserve-env=XDG_CACHE_DIR,XDG_CONFIG_DIR,XDG_DATA_DIR \
    --user "${VLC_USER}" \
    vlc -vvvv \
    --no-dbus \
    -A alsa --alsa-audio-device "${ALSA_DEVICE}" \
    -I telnet --telnet-host="${VLC_HOST}" --telnet-port="${VLC_PORT}" --telnet-password="${VLC_PASSWORD}"
