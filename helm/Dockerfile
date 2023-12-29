# syntax = docker/dockerfile:1.4
########################################
ARG APPVERSION
########################################

FROM golang:1.21-bullseye AS helm

WORKDIR /go/src/

ARG APPVERSION
RUN git clone --single-branch --depth 2 --branch release-${APPVERSION}-logs https://github.com/sergelogvinov/helm.git .
RUN make

########################################

FROM debian:bullseye-slim AS pkg
LABEL org.opencontainers.image.description="Helm with hook logs"

COPY --from=helm --chown=root:root /go/src/bin/helm /usr/bin/helm
ENTRYPOINT ["/usr/bin/helm"]
