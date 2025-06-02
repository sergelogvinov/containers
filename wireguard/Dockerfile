# syntax = docker/dockerfile:1.16
########################################
ARG APPVERSION=1.0.20250521
########################################

FROM alpine:3.22 AS pkg
LABEL org.opencontainers.image.description="Wireguard with utils" \
      org.opencontainers.image.licenses="MIT"

RUN apk --no-cache add wireguard-tools-wg wireguard-tools-wg-quick
COPY ["entrypoint.sh","/entrypoint.sh"]

EXPOSE 51820/udp
ENTRYPOINT ["/entrypoint.sh"]
