FROM rust:alpine as builder
LABEL org.opencontainers.image.authors="luis@cuarentaydos.com"

RUN apk add --no-cache \
	cargo \
	git
RUN git clone https://github.com/mbrubeck/agate.git /usr/src/agate && git -C /usr/src/agate checkout v3.3.0
RUN cargo install --path /usr/src/agate

FROM alpine
RUN apk add --no-cache \
	bash \
	tini \
	sudo
COPY --from=builder /usr/local/cargo/bin/agate /usr/bin/agate
COPY --from=builder /usr/src/agate/content /usr/share/agate/content

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 1965
VOLUME /content
ENTRYPOINT ["/sbin/tini", "-g", "--", "/entrypoint.sh"]
