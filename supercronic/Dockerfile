# syntax = docker/dockerfile:1.17
########################################
ARG APPVERSION=0.2.33
########################################

FROM --platform=$BUILDPLATFORM golang:1.25-trixie AS supercronic

WORKDIR /go/src/supercronic

ARG APPVERSION
RUN git clone --single-branch --depth 2 --branch v${APPVERSION} https://github.com/aptible/supercronic.git .

ENV CGO_ENABLED=0
RUN go mod vendor

RUN GOOS=linux GOARCH=amd64 go build -mod vendor -ldflags "-w -s -X main.Version=${APPVERSION}" -o dist/supercronic.linux.amd64 && \
    GOOS=linux GOARCH=arm64 go build -mod vendor -ldflags "-w -s -X main.Version=${APPVERSION}" -o dist/supercronic.linux.arm64 && \
    ./dist/supercronic.linux.`go env GOARCH` -test integration/env.crontab

########################################

FROM alpine:3.23 AS pkg

LABEL org.opencontainers.image.description="Supercronic is a crontab-compatible job runner, designed specifically to run in containers." \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.source="https://github.com/aptible/supercronic"

ARG TARGETARCH
COPY --from=supercronic ["/go/src/supercronic/dist/supercronic.linux.${TARGETARCH}","/usr/local/bin/supercronic"]

ENTRYPOINT ["/usr/local/bin/supercronic"]
