# syntax = docker/dockerfile:1.16
########################################
ARG APPVERSION
########################################

FROM --platform=$BUILDPLATFORM golang:1.23.8-bookworm AS builder

RUN apt-get update && apt-get install -y cmake git build-essential

ARG APPVERSION
WORKDIR /go/src/pvc-autoresizer
RUN git clone --single-branch --depth 2 --branch v${APPVERSION} https://github.com/topolvm/pvc-autoresizer.git .
RUN go mod download

ARG VERSION=${APPVERSION}
ENV CGO_ENABLED=0 GOOS=linux
RUN GOARCH=amd64 go build -o bin/pvc-autoresizer.amd64 -ldflags "-w -s" ./cmd && \
    GOARCH=arm64 go build -o bin/pvc-autoresizer.arm64 -ldflags "-w -s" ./cmd && \
    ./bin/pvc-autoresizer.`go env GOARCH` -h

#######

FROM --platform=${TARGETARCH} scratch AS pkg
LABEL org.opencontainers.image.description="Topolvm pvc autoresizer" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.source="https://github.com/topolvm/pvc-autoresizer.git"

ARG TARGETARCH
COPY --from=builder /go/src/pvc-autoresizer/bin/pvc-autoresizer.${TARGETARCH} /pvc-autoresizer

ENTRYPOINT ["/pvc-autoresizer"]
