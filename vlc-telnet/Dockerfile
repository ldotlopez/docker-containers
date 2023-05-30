FROM alpine
MAINTAINER luis@cuarentaydos.com

EXPOSE 4212/tcp

RUN apk add --no-cache \
    alsa-utils \
    bash \
    sudo \
    tini \
    vlc
COPY entrypoint.sh /

ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
