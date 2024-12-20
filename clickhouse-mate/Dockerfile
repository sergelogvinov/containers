# syntax = docker/dockerfile:1.11
########################################

FROM --platform=$BUILDPLATFORM alpine:3.21 AS build

RUN apk add --no-cache --update git wget

ARG APPVERSION=20230108154021
ENV APPVERSION=${APPVERSION}
WORKDIR /www
RUN wget https://github.com/metrico/clickhouse-mate/releases/download/${APPVERSION}/release.zip -O /tmp/clickhouse-mate.zip && \
    unzip /tmp/clickhouse-mate.zip -d /www

########################################

FROM ghcr.io/sergelogvinov/nginx-openresty:1.21.4.3 AS pkg
LABEL org.opencontainers.image.description="Advanced User-Interface for ClickHouse" \
      org.opencontainers.image.licenses="AGPL-3.0" \
      org.opencontainers.image.url="https://gigapipe.com/qryn/" \
      org.opencontainers.image.source="https://github.com/metrico/clickhouse-mate"

RUN apk add --no-cache --update curl && \
    install -o nginx -g nginx -d /run /tmp/cache && \
    rm -rf /tmp/* /run/*

WORKDIR /www
COPY --from=build ["/www","/www"]
COPY ["site.conf","/etc/nginx/http.d/default.conf"]

USER nginx
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
