FROM alpine
MAINTAINER luis@cuarentaydos.com

EXPOSE 4212/tcp

RUN apk add --no-cache tini sudo alsa-utils vlc bash
COPY entrypoint.sh /

ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
