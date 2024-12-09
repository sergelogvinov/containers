# syntax = docker/dockerfile:1.11
########################################
ARG APPVERSION
########################################

FROM alpine:3.21 AS pkg
LABEL org.opencontainers.image.description="IPSec with utils" \
      org.opencontainers.image.licenses="MIT"

RUN apk add openssl libreswan
COPY ["entrypoint.sh","/entrypoint.sh"]

EXPOSE 500/udp 4500/udp
ENTRYPOINT ["/entrypoint.sh"]
