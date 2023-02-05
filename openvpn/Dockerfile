# syntax = docker/dockerfile:1.4
########################################
ARG APPVERSION
########################################

FROM alpine:3.17 AS pkg
LABEL org.opencontainers.image.description="OpenVPN"
LABEL org.opencontainers.image.licenses="MIT"

RUN apk --update add openvpn iptables ip6tables && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/*

RUN mkdir -p /dev/net && \
    mknod /dev/net/tun c 10 200

WORKDIR /etc/openvpn
COPY ["server.conf","/etc/openvpn/server.conf"]

ENTRYPOINT ["/usr/sbin/openvpn"]
CMD ["--status","/tmp/openvpn.status","10","--config","/etc/openvpn/server.conf"]
