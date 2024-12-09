# syntax = docker/dockerfile:1.11
########################################
ARG APPVERSION=0.15.4
########################################

FROM --platform=$BUILDPLATFORM golang:1.19-bullseye AS chglog

WORKDIR /go/src

ARG APPVERSION
RUN git clone --single-branch --depth 2 --branch v${APPVERSION} https://github.com/git-chglog/git-chglog .

ENV CGO_ENABLED=0
RUN go mod download
RUN GOOS=linux GOARCH=amd64 go build -ldflags "-w -s -X main.version=${APPVERSION}" -o dist/git-chglog.linux.amd64 ./cmd/git-chglog && \
    GOOS=linux GOARCH=arm64 go build -ldflags "-w -s -X main.version=${APPVERSION}" -o dist/git-chglog.linux.arm64 ./cmd/git-chglog && \
    ./dist/git-chglog.linux.`go env GOARCH` -version

########################################

FROM alpine:3.21 AS pkg

LABEL org.opencontainers.image.description="CHANGELOG generator implemented in Go" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.source="https://github.com/git-chglog/git-chglog"

ARG TARGETARCH
COPY --from=chglog ["/go/src/dist/git-chglog.linux.${TARGETARCH}","/usr/local/bin/git-chglog"]
