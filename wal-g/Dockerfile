# syntax = docker/dockerfile:1.16
########################################
ARG APPVERSION=v3.0.7
########################################

FROM golang:1.22-bookworm AS walg-base

RUN apt-get update && apt-get install -y cmake git build-essential

WORKDIR /go/src/

ARG APPVERSION
RUN git clone --single-branch --depth 2 --branch ${APPVERSION} https://github.com/wal-g/wal-g.git .
# Fix: fail if commit has two tags
RUN git tag -d v3.0.6 ||:

ENV USE_LIBSODIUM=1 USE_BROTLI=1
ENV GOBIN=/usr/local/bin
RUN make deps

FROM walg-base AS walg-pg
RUN make pg_install && /usr/local/bin/wal-g --version

FROM walg-base AS walg-mongo
RUN make mongo_install && /usr/local/bin/wal-g --version

FROM walg-base AS walg-redis
RUN make redis_install && /usr/local/bin/wal-g --version

########################################

FROM registry.k8s.io/pause:3.10 AS pause

########################################

FROM debian:bookworm-slim AS pkg
LABEL org.opencontainers.image.description="Wal-g" \
      org.opencontainers.image.licenses="MIT"

COPY --from=pause       ["/pause","/pause"]
COPY --from=walg-pg     ["/usr/local/bin/wal-g","/usr/local/bin/wal-g-pg"]
COPY --from=walg-mongo  ["/usr/local/bin/wal-g","/usr/local/bin/wal-g-mongo"]
COPY --from=walg-redis  ["/usr/local/bin/wal-g","/usr/local/bin/wal-g-redis"]

########################################

FROM debian:bookworm-slim AS pg
LABEL org.opencontainers.image.description="Wal-g for postgresql" \
      org.opencontainers.image.licenses="MIT"

COPY --from=pause       ["/pause","/pause"]
COPY --from=walg-pg     ["/usr/local/bin/wal-g","/usr/local/bin/wal-g"]

########################################

FROM debian:bookworm-slim AS mongo
LABEL org.opencontainers.image.description="Wal-g for mongo" \
      org.opencontainers.image.licenses="MIT"

COPY --from=pause       ["/pause","/pause"]
COPY --from=walg-mongo  ["/usr/local/bin/wal-g","/usr/local/bin/wal-g"]

########################################

FROM debian:bookworm-slim AS redis
LABEL org.opencontainers.image.description="Wal-g for redis" \
      org.opencontainers.image.licenses="MIT"

COPY --from=pause       ["/pause","/pause"]
COPY --from=walg-redis  ["/usr/local/bin/wal-g","/usr/local/bin/wal-g"]
