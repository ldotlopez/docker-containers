FROM alpine
# EXPOSE 4212
MAINTAINER luis@cuarentaydos.com
RUN apk add --no-cache vlc alsa-utils tini bash
COPY entrypoint.sh /

# Allways execute tini
# ENTRYPOINT [ "/sbin/tini", "--", "/entrypoint.sh" ]

# By default execute an interactive shell (executes ~/.bashrc)
# CMD ["/bin/bash", "-i"]


ENTRYPOINT ["/sbin/tini", "--"]

# Run your program under Tini
CMD ["/entrypoint.sh"]
