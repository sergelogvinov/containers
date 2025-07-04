# syntax = docker/dockerfile:1.16
########################################
ARG APPVERSION=0.52.0
########################################

FROM --platform=$BUILDPLATFORM golang:1.24-bookworm AS ytt

WORKDIR /go/src/ytt

ARG APPVERSION
RUN git clone --single-branch --depth 2 --branch v${APPVERSION} https://github.com/carvel-dev/ytt.git .

ENV CGO_ENABLED=0
RUN go mod vendor

ENV LDFLAGS="-w -s -X carvel.dev/ytt/pkg/version.Version=$APPVERSION"
RUN GOOS=linux GOARCH=amd64 go build -mod vendor -ldflags="$LDFLAGS" -o dist/ytt.linux.amd64 ./cmd/ytt && \
    GOOS=linux GOARCH=arm64 go build -mod vendor -ldflags="$LDFLAGS" -o dist/ytt.linux.arm64 ./cmd/ytt && \
    ./dist/ytt.linux.`go env GOARCH` --version

########################################

FROM alpine:3.22 AS pkg

LABEL org.opencontainers.image.description="YTT is a templating tool that understands YAML structure." \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.source="https://github.com/carvel-dev/ytt"

ARG TARGETARCH
COPY --from=ytt ["/go/src/ytt/dist/ytt.linux.${TARGETARCH}","/usr/local/bin/ytt"]
