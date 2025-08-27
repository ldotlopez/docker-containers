#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

PUID="${PUID:-0}"
PGID="${PGID:-0}"
AGATE_HOSTNAME="${AGATE_HOSTNAME:-localhost}"
AGATE_LANG="${AGATE_LANG:-en-US}"
AGATE_CONTENT="/content"
AGATE_CERTIFICATES="${CERTIFICATES:-${AGATE_CONTENT}/.certificates}"

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
	adduser -G "$GROUPNAME" -u "$PUID" -H -D -h "$AGATE_CONTENT" "$USERNAME"
fi

#
# Setup agate stuff
#

[[ -d "$AGATE_CONTENT" ]] || mkdir "$AGATE_CONTENT"
[[ -d "$AGATE_CERTIFICATES" ]] || mkdir "$AGATE_CERTIFICATES"
sudo chown -R "$PUID:$PGID" "$AGATE_CONTENT" "$AGATE_CERTIFICATES"

if [[ ! -f "$AGATE_CONTENT/index.gmi" ]]; then
	cp -r /usr/share/agate/content/* "$AGATE_CONTENT/"
	chown -R "$PUID:$PGID" "$AGATE_CONTENT"
fi

#
# Run agate
#

echo "[*] Running as: '$USERNAME:$GROUPNAME' ($PUID:$PGID)"
echo "[*]         addr: '0.0.0.0:1965' and '[::]:1965'"
echo "[*]         content: '$AGATE_CONTENT'"
echo "[*]         certificates: '$AGATE_CERTIFICATES'"
echo "[*]         hostname: '$AGATE_HOSTNAME'"
echo "[*]         language: '$AGATE_LANG'"

exec sudo \
	--user="$USERNAME" \
	--group="$GROUPNAME" \
	"/usr/bin/agate" \
	"--addr" '0.0.0.0:1965' \
	"--addr" '[::]:1965' \
	"--content" "$AGATE_CONTENT" \
	"--certs" "$AGATE_CERTIFICATES" \
	"--hostname" "$AGATE_HOSTNAME" \
	"--lang" "$AGATE_LANG"
