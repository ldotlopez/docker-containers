FROM alpine
MAINTAINER luis@cuarentaydos.com

EXPOSE 4212/tcp

RUN apk add --no-cache vlc alsa-utils tini bash sudo
COPY entrypoint.sh /

ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
