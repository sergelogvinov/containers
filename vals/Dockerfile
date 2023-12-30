# syntax = docker/dockerfile:1.4
########################################
ARG APPVERSION
########################################

FROM golang:1.21-bookworm AS vals

RUN apt-get update && apt-get install -y git build-essential

WORKDIR /go/src/

ARG APPVERSION
RUN git clone --single-branch --depth 2 --branch v${APPVERSION} https://github.com/helmfile/vals .

ENV CGO_ENABLED=0
RUN make build && ./bin/vals version

########################################

FROM alpine:3.18 AS pkg
LABEL org.opencontainers.image.description="Vals is a tool for managing configuration values and secrets" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.source="https://github.com/helmfile/vals"

ARG TARGETARCH
COPY --from=vals ["/go/src/bin/vals","/usr/bin/vals"]
