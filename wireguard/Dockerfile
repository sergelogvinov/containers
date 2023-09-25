# syntax = docker/dockerfile:1.4
########################################
ARG APPVERSION
########################################

FROM alpine:3.18 AS pkg
LABEL org.opencontainers.image.description="Wireguard with utils" \
      org.opencontainers.image.licenses="MIT"

RUN apk add wireguard-tools-wg wireguard-tools-wg-quick
COPY ["entrypoint.sh","/entrypoint.sh"]

EXPOSE 51820/udp
ENTRYPOINT ["/entrypoint.sh"]
