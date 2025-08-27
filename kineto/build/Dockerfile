FROM alpine as builder

RUN apk add --no-cache go git
RUN git clone https://git.sr.ht/~sircmpwn/kineto /usr/src/kineto
RUN cd /usr/src/kineto && go build

FROM alpine
RUN apk add --no-cache \
    bash \
    tini \
    sudo
COPY --from=builder \
    /usr/src/kineto/kineto \
    /usr/bin/kineto

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80/tcp

ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
