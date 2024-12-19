# syntax = docker/dockerfile:1.11
########################################
ARG APPVERSION=1.11.1
########################################

FROM alpine:3.21 AS pkg
LABEL org.opencontainers.image.description="Tinyproxy" \
      org.opencontainers.image.licenses="MIT"

RUN apk --update --no-cache add tinyproxy
COPY ["etc/","/etc/tinyproxy/"]

USER tinyproxy

ENTRYPOINT ["/usr/bin/tinyproxy"]
CMD ["-d","-c","/etc/tinyproxy/tinyproxy.conf"]
