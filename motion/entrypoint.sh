#!/bin/bash

generate_override_config() {
	while IFS= read -r -d $'\0' PAIR; do
		# Check only for MOTION_ envvars
		[[ $PAIR == MOTION_* ]] || continue

		# Do ONE split on PAIR
		IFS=$'\n' read -d "" -ra PARTS <<<"${PAIR/=/$'\n'}"
		KEY="${PARTS[0]}"
		VALUE="${PARTS[1]}"

		# Strip motion prefix
		KEY="${KEY#MOTION_}"

		# Lowercase KEY
		KEY="${KEY,,}"

		printf "[docker]: '%s' => '%s'\n" "$KEY" "$VALUE" >&2
		printf "%s %s\n" "$KEY" "$VALUE"
	done < <(cat /proc/self/environ)
}

generate_mqtt_config() {
	[[ -z "$MQTT_PREFIX" ]] && return

	MQTT_HOST="${MQTT_HOST:-localhost}"
	MQTT_PREFIX="${MQTT_PREFIX%%/}"
	printf "[docker]: Generation conf for 'mqtt://%s/%s'\n" "$MQTT_HOST" "$MQTT_PREFIX" >&2
	cat <<-EOF
		on_event_start  /usr/bin/mosquitto_pub -h "$MQTT_HOST" -t "$MQTT_PREFIX/motion"    -m on
		on_event_end    /usr/bin/mosquitto_pub -h "$MQTT_HOST" -t "$MQTT_PREFIX/motion"    -m off
		on_camera_lost  /usr/bin/mosquitto_pub -h "$MQTT_HOST" -t "$MQTT_PREFIX/available" -m off
		on_camera_found /usr/bin/mosquitto_pub -h "$MQTT_HOST" -t "$MQTT_PREFIX/available" -m on
	EOF
}

TMPF="$(mktemp)"
(
	cat /conf/motion.conf
	generate_override_config
	generate_mqtt_config
) >"$TMPF" && mv "$TMPF" /conf/motion.conf

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

exec sudo -u "$(id -n -u "$PUID")" -n \
	/usr/bin/tini -s /usr/bin/motion -- -c "/conf/motion.conf"
