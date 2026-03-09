# syntax = docker/dockerfile:1.22
########################################
ARG APPVERSION
########################################

FROM alpine:3.23 AS pkg
LABEL org.opencontainers.image.description="IPtables" \
      org.opencontainers.image.licenses="MIT"

RUN apk --update add iptables ip6tables && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/*
