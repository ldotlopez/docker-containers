#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

PUID="${PUID:-0}"
PGID="${PGID:-0}"
HOSTNAME="${HOSTNAME:-localhost}"
LANG="${LANG:-en-US}"
CONTENT="/content"
CERTIFICATES="${CERTIFICATES:-${CONTENT}/.certificates}"

#
# Setup process support
#

GROUPNAME="$( (getent group "$PGID" 2>/dev/null || true) | cut -d ':' -f 1)"
if [[ -z "$GROUPNAME" ]]; then
	GROUPNAME="abc"
	echo "[*] Creating group '$GROUPNAME' with GID $PGID"
	addgroup -g "$PGID" "$GROUPNAME"
fi

USERNAME="$( (getent passwd "$PUID" 2>/dev/null || true) | cut -d ':' -f 1)"
if [[ -z "$USERNAME" ]]; then
	USERNAME="abc"
	echo "[*] Creating user '$USERNAME' with UID $PUID"
	adduser -G "$GROUPNAME" -u "$PUID" -H -D -h "$CONTENT" "$USERNAME"
fi

#
# Setup agate stuff
#

[[ -d "$CONTENT" ]] || mkdir "$CONTENT"
[[ -d "$CERTIFICATES" ]] || mkdir "$CERTIFICATES"
sudo chown -R "$PUID:$PGID" "$CONTENT" "$CERTIFICATES"

if [[ ! -f "$CONTENT/index.gmi" ]]; then
	echo "[*] Creating index.gmi"
	cat >"$CONTENT/index.gmi" <<-EOF
		# Hello

		This is "$HOSTNAME"
	EOF
fi

#
# Run agate
#

echo "[*] Running agate process: '$USERNAME:$GROUPNAME' ($PUID:$PGID)"
echo "[*] Running agate addr: '0.0.0.0:1965' and '[::]:1965'"
echo "[*] Running agate content: '$CONTENT'"
echo "[*] Running agate certificates: '$CERTIFICATES'"
echo "[*] Running agate hostname: '$HOSTNAME'"
echo "[*] Running agate language: '$LANG'"
exec sudo \
	--user="$USERNAME" \
	--group="$(getent group "$PUID" | cut -d : -f 1)" \
	/usr/bin/agate \
	--addr '0.0.0.0:1965' \
	--addr '[::]:1965' \
	--content "$CONTENT" \
	--certs "$CERTIFICATES" \
	--hostname "$HOSTNAME" \
	--lang "$LANG"
