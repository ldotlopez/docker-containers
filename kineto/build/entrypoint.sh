#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

#
# Process ownership
#

PUID="${PUID:-0}"
PGID="${PGID:-0}"

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
	adduser -G "$GROUPNAME" -u "$PUID" -H -D -h "$AGATE_CONTENT" "$USERNAME"
fi

#
# Run kineto
#

CMDL="/usr/bin/kineto"
CMDL+=("-b" "0.0.0.0:80")
if [[ -n "$CSS_FILEPATH" ]]; then
	CMDL+=("-s" "$CSS_FILEPATH")
fi
CMDL+=("$GEMINI_URL")

echo "[*] Running as: '$USERNAME:$GROUPNAME' ($PUID:$PGID)"
echo "[*]         bind: '0.0.0.0:80'"
echo "[*]         gemini url: '${GEMINI_URL}'"
echo "[*]         css file: '${CSS_FILEPATH:-(none)}'"

# kineto [-b 127.0.0.1:8080] [-s style.css] [-e style.css] gemini://example.org
exec sudo \
	--user="$USERNAME" \
	--group="$GROUPNAME" \
	"${CMDL[@]}"
