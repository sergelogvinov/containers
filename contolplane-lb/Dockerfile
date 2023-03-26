# syntax = docker/dockerfile:1.4
########################################
ARG APPVERSION
########################################

FROM alpine:3.17 AS builder

RUN apk add --no-cache haproxy && \
    install -m 0750 -o haproxy -g haproxy -d /run

COPY haproxy.cfg /etc/haproxy/haproxy.cfg

ENTRYPOINT ["/usr/sbin/haproxy"]
CMD ["-f","/etc/haproxy/haproxy.cfg"]
