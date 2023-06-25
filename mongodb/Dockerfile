# syntax = docker/dockerfile:1.4
########################################
ARG APPVERSION
########################################

FROM ghcr.io/sergelogvinov/wal-g:2.0.1-mongo AS walg

########################################

FROM registry.k8s.io/pause:3.6 AS pause

########################################

FROM bitnami/mongodb:${APPVERSION}-debian-11-r14 AS pkg
LABEL org.opencontainers.image.description="Mongodb with utils" \
      org.opencontainers.image.licenses="MIT"

COPY --from=pause    ["/pause","/pause"]
COPY --from=walg     ["/usr/local/bin/wal-g","/usr/bin/wal-g"]

########################################

FROM mongo:${APPVERSION} AS official
LABEL org.opencontainers.image.description="Mongodb official with utils" \
      org.opencontainers.image.licenses="MIT"

COPY --from=pause    ["/pause","/pause"]
COPY --from=walg     ["/usr/local/bin/wal-g","/usr/bin/wal-g"]
