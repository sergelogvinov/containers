# syntax = docker/dockerfile:1.4
########################################

FROM golang:1.18-bullseye AS walg

RUN apt-get update && apt-get install -y cmake git build-essential

WORKDIR /go/src/
ENV USE_LIBSODIUM=1
RUN git clone --single-branch --depth 2 --branch v2.0.1 https://github.com/wal-g/wal-g.git .

ENV GOBIN=/usr/local/bin
RUN make deps
RUN make redis_install && /usr/local/bin/wal-g --version

########################################

FROM scratch AS keydb

COPY --from=eqalpha/keydb:x86_64_v6.3.3 ["/usr/local/bin/",   "amd64/"]
COPY --from=eqalpha/keydb:arm64_v6.3.3  ["/usr/local/bin/",   "arm64/"]

########################################

# FROM redis:6.2.7 AS redis

########################################

FROM debian:bullseye-slim AS pkg
LABEL org.opencontainers.image.description="Keydb with utils" \
      org.opencontainers.image.licenses="MIT"

RUN groupadd -r -g 999 redis && useradd -r -g redis -u 999 redis
ENV REDIS_USER=redis REDIS_DATA_DIR=/data

EXPOSE 6379

RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4 \
    libc6 \
    libssl1.1 \
    libuuid1 \
    libstdc++6 \
    libgcc1 \
    zlib1g \
    libbz2-1.0 \
    liblz4-1 \
    libsnappy1v5 \
    libzstd1 \
    libatomic1 \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

COPY redis.conf /etc/redis.conf
COPY ["bin/*","/sbin/"]
RUN install -m 0755 -o redis -g redis -d /run/redis -d $REDIS_DATA_DIR && \
    ln -s /usr/bin/keydb-server /usr/local/bin/redis-server && \
    chmod 755 /sbin/entrypoint.sh

COPY --from=walg  ["/usr/local/bin/wal-g","/usr/bin/wal-g"]

ARG TARGETARCH
COPY --from=keydb ["/${TARGETARCH}/keydb-server",   "/usr/bin/keydb-server"]
COPY --from=keydb ["/${TARGETARCH}/keydb-cli",      "/usr/bin/redis-cli"]

USER redis
VOLUME ["${REDIS_DATA_DIR}"]
ENTRYPOINT ["/sbin/entrypoint.sh"]
