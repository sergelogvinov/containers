# syntax = docker/dockerfile:1.21
########################################
ARG APPVERSION=3.4.1
########################################

FROM alpine:3.22 AS pkg
LABEL org.opencontainers.image.description="Rsync with utils" \
      org.opencontainers.image.licenses="MIT"

RUN apk add rsync
COPY ["rsyncd.conf", "/etc/rsyncd.conf"]

EXPOSE 1873/tcp
ENTRYPOINT ["/usr/bin/rsync","--daemon","--no-detach"]
ARG ["--config", "/etc/rsyncd.conf"]
