# syntax = docker/dockerfile:1.11
########################################
ARG APPVERSION
########################################

FROM alpine:3.21 AS pkg
LABEL org.opencontainers.image.description="Kubernetes lb" \
      org.opencontainers.image.licenses="MIT"

RUN apk add --no-cache haproxy && \
    install -m 0750 -o haproxy -g haproxy -d /run

COPY haproxy.cfg /etc/haproxy/haproxy.cfg

ENTRYPOINT ["/usr/sbin/haproxy"]
CMD ["-f","/etc/haproxy/haproxy.cfg"]
