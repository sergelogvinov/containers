# syntax = docker/dockerfile:1.4
########################################
ARG APPVERSION
########################################

FROM golang:1.18-bullseye AS walg-base

RUN apt-get update && apt-get install -y cmake git build-essential

WORKDIR /go/src/
ENV USE_LIBSODIUM=1

ARG APPVERSION
RUN git clone --single-branch --depth 2 --branch v${APPVERSION} https://github.com/wal-g/wal-g.git .

ENV GOBIN=/usr/local/bin
RUN make deps

FROM walg-base AS walg-pg
RUN make pg_install && /usr/local/bin/wal-g --version

FROM walg-base AS walg-mongo
RUN make mongo_install && /usr/local/bin/wal-g --version

FROM walg-base AS walg-redis
RUN make redis_install && /usr/local/bin/wal-g --version

########################################

FROM registry.k8s.io/pause:3.6 AS pause

########################################

FROM alpine:3.18 AS pg
LABEL org.opencontainers.image.description="Wal-g for postgresql" \
      org.opencontainers.image.licenses="MIT"

COPY --from=pause       ["/pause","/pause"]
COPY --from=walg-pg     ["/usr/local/bin/wal-g","/usr/local/bin/wal-g"]

########################################

FROM alpine:3.18 AS mongo
LABEL org.opencontainers.image.description="Wal-g for mongo" \
      org.opencontainers.image.licenses="MIT"

COPY --from=pause       ["/pause","/pause"]
COPY --from=walg-mongo  ["/usr/local/bin/wal-g","/usr/local/bin/wal-g"]

########################################

FROM alpine:3.18 AS redis
LABEL org.opencontainers.image.description="Wal-g for redis" \
      org.opencontainers.image.licenses="MIT"

COPY --from=pause       ["/pause","/pause"]
COPY --from=walg-redis  ["/usr/local/bin/wal-g","/usr/local/bin/wal-g"]
