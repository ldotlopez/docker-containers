#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

USER_USER="abc"
USER_GROUP="abc"

USER_UID="${PUID:-1000}"
USER_GID="${PGID:-1000}"

VLC_PORT="${VLC_PORT:-4212}"
VLC_PASSWORD="${VLC_PASSWORD:-password}"

if [ ! -e /.configured ]; then
   echo "*** Configuring container ***"

   addgroup -g "$USER_GID" "$USER_GROUP"
   adduser -u "$USER_UID" -h / -g '' -G "$USER_GROUP" -D -H "$USER_USER"

   addgroup -g "$(stat -c %g /dev/snd/timer)" -S alsa
   adduser "$USER_USER" alsa

   touch "/.configured"
fi

USER_UID="$(id -u $USER_USER)"
USER_GID="$(id -g $USER_USER)"

echo "*** Starting vlc as user: ${USER_USER} (uid:${USER_UID}/gid:${USER_GID}) ***"
su -l - "$USER_USER" -c "vlc-wrapper -I telnet --telnet-host=127.0.0.1 --telnet-port '$VLC_PORT' --telnet-password '$VLC_PASSWORD'"
