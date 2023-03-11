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
RUN make mongo_install && /usr/local/bin/wal-g --version

########################################

FROM bitnami/mongodb:${APPVERSION}-debian-11-r16 AS pkg
LABEL org.opencontainers.image.description="Mongodb with utils"
LABEL org.opencontainers.image.licenses=MIT

COPY --from=walg     ["/usr/local/bin/wal-g","/usr/bin/wal-g"]
