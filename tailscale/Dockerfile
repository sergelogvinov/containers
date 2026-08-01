# syntax = docker/dockerfile:1.24
########################################
ARG APPVERSION=v1.98.8
########################################

FROM ghcr.io/tailscale/tailscale:${APPVERSION} AS tailscale

########################################

FROM alpine:3.24 AS pkg
LABEL org.opencontainers.image.description="The easiest, most secure way to use WireGuard and 2FA" \
      org.opencontainers.image.licenses="BSD 3-Clause License" \
      org.opencontainers.image.source="https://github.com/tailscale/tailscale"

RUN apk add --no-cache ca-certificates iptables iproute2 ip6tables

COPY --from=tailscale ["/usr/local/bin/*","/usr/local/bin/"]
RUN mkdir /tailscale && ln -s /usr/local/bin/containerboot /tailscale/run.sh
ENTRYPOINT ["/usr/local/bin/tailscale"]
