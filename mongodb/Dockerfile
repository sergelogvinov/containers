# syntax = docker/dockerfile:1.21
########################################
ARG APPVERSION=8
########################################

FROM ghcr.io/sergelogvinov/wal-g:v3.0.7-mongo AS walg

########################################

FROM registry.k8s.io/pause:3.10 AS pause

########################################

FROM --platform=linux/amd64 bitnami/mongodb:${APPVERSION}-debian-12-r1 AS pkg
ARG APPVERSION
LABEL org.opencontainers.image.description="Mongodb with utils" \
      org.opencontainers.image.documentation="https://www.mongodb.com" \
      org.opencontainers.image.url="https://github.com/bitnami/containers/tree/main/bitnami/mongodb" \
      org.opencontainers.image.version=${APPVERSION}

COPY --from=pause    ["/pause","/pause"]
COPY --from=walg     ["/usr/local/bin/wal-g","/usr/bin/wal-g"]

########################################

FROM mongo:${APPVERSION} AS official
ARG APPVERSION
LABEL org.opencontainers.image.description="Mongodb official with utils" \
      org.opencontainers.image.documentation="https://www.mongodb.com" \
      org.opencontainers.image.version=${APPVERSION}

COPY --from=pause    ["/pause","/pause"]
COPY --from=walg     ["/usr/local/bin/wal-g","/usr/bin/wal-g"]
