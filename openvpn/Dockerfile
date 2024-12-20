# syntax = docker/dockerfile:1.11
########################################
ARG APPVERSION
########################################

FROM alpine:3.21 AS pkg
LABEL org.opencontainers.image.description="OpenVPN" \
      org.opencontainers.image.licenses="MIT"

RUN apk --update add openvpn openvpn-auth-pam google-authenticator iptables ip6tables && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/*

RUN mkdir -p /dev/net && \
    mknod /dev/net/tun c 10 200

WORKDIR /etc/openvpn
COPY ["server.conf","/etc/openvpn/server.conf"]
COPY ["pam.d/","/etc/pam.d/"]

ENTRYPOINT ["/usr/sbin/openvpn"]
CMD ["--status","/tmp/openvpn.status","10","--config","/etc/openvpn/server.conf"]
