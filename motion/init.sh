#!/bin/bash

PUID=${PUID:-0}
[[ "$PGID" != 0 ]] &&
	addgroup \
		--gid "$PGID" \
		abc

PGID=${PGID:-0}
[[ "$PUID" != 0 ]] &&
	adduser \
		--uid "$PUID" \
		--gid "$PGID" \
		--gecos "" \
		--home /conf \
		--no-create-home \
		--disabled-password \
		abc

chown "$PUID:$PGID" /conf /conf/motion.conf /data
chmod 755 /conf /data

exec sudo -u "$(id -n -u "$PUID")" -n /entrypoint.sh
