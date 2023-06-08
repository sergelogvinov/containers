# syntax = docker/dockerfile:1.4
########################################
ARG APPVERSION
########################################

FROM golang:1.18-bullseye AS walg

RUN apt-get update && apt-get install -y cmake git build-essential

WORKDIR /go/src/
ENV USE_LIBSODIUM=1
RUN git clone --single-branch --depth 2 --branch v2.0.1 https://github.com/wal-g/wal-g.git .

ENV GOBIN=/usr/local/bin
RUN make deps
RUN make pg_install && /usr/local/bin/wal-g --version

########################################

FROM --platform=$BUILDPLATFORM golang:1.16 as pgcenter

WORKDIR /go/src/pgcenter

RUN git clone --single-branch --depth 2 -b v0.9.2 https://github.com/lesovsky/pgcenter.git .

ARG TARGETOS TARGETARCH
ENV GOOS $TARGETOS
ENV GOARCH $TARGETARCH
RUN make build && make install

########################################

FROM registry.k8s.io/pause:3.6 AS pause

########################################

FROM postgres:${APPVERSION}-bullseye AS pkg
LABEL org.opencontainers.image.description="Postgresql with utils" \
      org.opencontainers.image.licenses="MIT"

RUN apt-get update -y && apt-get install -y --no-install-recommends ca-certificates rsync curl vim-tiny openssh-server pgbadger barman-cli && \
    rm -rf /etc/crontab /etc/cron.hourly/ /etc/cron.daily/ /etc/cron.weekly/ /etc/cron.monthly/ /etc/cron.d/* && \
    mkdir -p /var/run/sshd && echo '' > /etc/motd && \
    chgrp postgres -R /etc/ssl/private && \
    install -o postgres -g postgres -m 0750 -d /var/lib/postgresql/.ssh && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY ["ssh", "/etc/ssh"]
COPY --from=pause    ["/pause","/pause"]
COPY --from=pgcenter ["/usr/bin/pgcenter","/usr/bin/pgcenter"]
COPY --from=walg     ["/usr/local/bin/wal-g","/usr/bin/wal-g"]
COPY docker-entrypoint.sh /usr/local/bin/
