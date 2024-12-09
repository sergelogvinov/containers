# syntax = docker/dockerfile:1.11
########################################
ARG APPVERSION=0.17.2
########################################

FROM --platform=$BUILDPLATFORM golang:1.21-bullseye AS reviewdog

RUN apt-get update && apt-get install -y git build-essential

WORKDIR /go/src/

ARG APPVERSION
RUN git clone --single-branch --depth 2 --branch v${APPVERSION} https://github.com/reviewdog/reviewdog.git .

ENV CGO_ENABLED=0
RUN go mod vendor

ENV LDFLAGS="-w -s -X github.com/reviewdog/reviewdog/commands.Version=${APPVERSION}"
RUN GOOS=linux GOARCH=amd64 go build -mod vendor -ldflags="$LDFLAGS" -o dist/reviewdog.linux.amd64 ./cmd/reviewdog && \
    GOOS=linux GOARCH=arm64 go build -mod vendor -ldflags="$LDFLAGS" -o dist/reviewdog.linux.arm64 ./cmd/reviewdog && \
    ./dist/reviewdog.linux.`go env GOARCH` -version

########################################

FROM alpine:3.21 AS pkg
LABEL org.opencontainers.image.description="Automated code review tool integrated with any code analysis tools regardless of programming language" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.source="https://github.com/reviewdog/reviewdog"

ARG TARGETARCH
COPY --from=reviewdog ["/go/src/dist/reviewdog.linux.${TARGETARCH}","/usr/bin/reviewdog"]

ENTRYPOINT ["/usr/bin/reviewdog"]
