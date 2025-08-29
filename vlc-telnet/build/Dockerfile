FROM alpine:latest
LABEL org.opencontainers.image.authors="luis@cuarentaydos.com"

EXPOSE 4212/tcp

RUN apk add --no-cache \
    alsa-utils \
    bash \
    sudo \
    tini \
    vlc
COPY entrypoint.sh /

HEALTHCHECK \
  --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD nc -z localhost 4212 || exit 1

ENTRYPOINT ["/sbin/tini", "-g", "--"]

CMD ["/entrypoint.sh"]
