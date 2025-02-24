# syntax = docker/dockerfile:1.14
########################################
ARG APPVERSION
########################################

FROM ghcr.io/sergelogvinov/wal-g:v3.0.3-redis AS walg

########################################

FROM scratch AS keydb

COPY --from=eqalpha/keydb:x86_64_v6.3.4 ["/usr/local/bin/",   "amd64/"]
COPY --from=eqalpha/keydb:arm64_v6.3.4  ["/usr/local/bin/",   "arm64/"]

########################################

FROM redis:6.2.12-bullseye AS redis

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
COPY --from=keydb ["/${TARGETARCH}/keydb-check-rdb","/usr/bin/keydb-check-rdb"]
COPY --from=keydb ["/${TARGETARCH}/keydb-cli",      "/usr/bin/keydb-cli"]
COPY --from=redis ["/usr/local/bin/redis-cli",      "/usr/bin/redis-cli"]

# RUN redis-cli --version && \
#     keydb-server --version && \
#     wal-g --version

USER redis
VOLUME ["${REDIS_DATA_DIR}"]
ENTRYPOINT ["/sbin/entrypoint.sh"]
