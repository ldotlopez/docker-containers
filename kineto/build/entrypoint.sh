#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

PUID="${PUID:-0}"
PGID="${PGID:-0}"

GEMINI_URL="${GEMINI_URL:-gemini://localhost}"
CSS_FILEPATH="${CSS_FILEPATH:-}"

if ! (getent group "$PGID" 1>/dev/null 2>/dev/null); then
	addgroup -g "$PGID" kineto
fi

if ! (getent passwd "$PUID" 1>/dev/null 2>/dev/null); then
	adduser -G kineto -u 1000 -H -D agate
fi

CMDL="/usr/bin/kineto"
CMDL+=("-b" "0.0.0.0:80")
if [[ -n "$CSS_FILEPATH" ]]; then
	CMDL+=("-s" "$CSS_FILEPATH")
fi
CMDL+=("$GEMINI_URL")

# kineto [-b 127.0.0.1:8080] [-s style.css] [-e style.css] gemini://example.org
exec sudo \
	--user="$(getent passwd "$PUID" | cut -d : -f 1)" \
	--group="$(getent group "$PUID" | cut -d : -f 1)" \
	"${CMDL[@]}"
