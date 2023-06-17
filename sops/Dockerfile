# syntax = docker/dockerfile:1.4
########################################
ARG APPVERSION
########################################

FROM --platform=$BUILDPLATFORM golang:1.17-bullseye AS sops

RUN apt-get update && apt-get install -y git build-essential

WORKDIR /go/src/go.mozilla.org/sops

ARG APPVERSION
RUN git clone --single-branch --depth 2 --branch v${APPVERSION} https://github.com/mozilla/sops .

ENV CGO_ENABLED=0
RUN go mod vendor

RUN GOOS=linux GOARCH=amd64 go build -mod vendor -ldflags "-w -s" -o dist/sops.linux.amd64 go.mozilla.org/sops/v3/cmd/sops && \
    GOOS=linux GOARCH=arm64 go build -mod vendor -ldflags "-w -s" -o dist/sops.linux.arm64 go.mozilla.org/sops/v3/cmd/sops && \
    ./dist/sops.linux.`go env GOARCH` -v

########################################

FROM alpine:3.18 AS pkg
LABEL org.opencontainers.image.description="Sops is an editor of encrypted files that supports YAML, JSON and BINARY formats and encrypts with AWS KMS and PGP." \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.source="https://github.com/mozilla/sops"

ARG TARGETARCH
COPY --from=sops ["/go/src/go.mozilla.org/sops/dist/sops.linux.${TARGETARCH}","/usr/bin/sops"]
