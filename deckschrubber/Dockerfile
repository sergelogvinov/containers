# syntax = docker/dockerfile:1.6
########################################
ARG APPVERSION
########################################

FROM --platform=$BUILDPLATFORM golang:1.23-bookworm AS deckschrubber

RUN apt-get update && apt-get install -y git build-essential

WORKDIR /go/src/

ARG APPVERSION
RUN git clone --single-branch --depth 2 --branch v${APPVERSION} https://github.com/fraunhoferfokus/deckschrubber .

ENV CGO_ENABLED=0
RUN go mod download
RUN GOOS=linux GOARCH=amd64 go build -ldflags "-w -s" -o dist/deckschrubber.linux.amd64 && \
    GOOS=linux GOARCH=arm64 go build -ldflags "-w -s" -o dist/deckschrubber.linux.arm64 && \
    ./dist/deckschrubber.linux.`go env GOARCH` -v

########################################

FROM alpine:3.19 AS pkg
LABEL org.opencontainers.image.description="Deckschrubber inspects images and removes those older than a given age" \
      org.opencontainers.image.licenses="AGPL-3.0" \
      org.opencontainers.image.source="https://github.com/fraunhoferfokus/deckschrubber"

ARG TARGETARCH
COPY --from=deckschrubber ["/go/src/dist/deckschrubber.linux.${TARGETARCH}","/usr/bin/deckschrubber"]
ENTRYPOINT ["/usr/bin/deckschrubber"]
