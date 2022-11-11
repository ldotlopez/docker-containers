FROM ubuntu:20.10

VOLUME /data
VOLUME /conf

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get install -y motion mosquitto-clients tini sudo

COPY entrypoint.sh /entrypoint.sh
COPY motion.conf /conf/motion.conf

ENTRYPOINT ["/entrypoint.sh"]
