# syntax = docker/dockerfile:1.26
########################################
ARG APPVERSION=1.102.3
########################################

FROM ghcr.io/tailscale/tailscale:v${APPVERSION} AS tailscale

########################################

FROM alpine:3.24 AS pkg
LABEL org.opencontainers.image.description="The easiest, most secure way to use WireGuard and 2FA" \
      org.opencontainers.image.licenses="BSD 3-Clause License" \
      org.opencontainers.image.source="https://github.com/tailscale/tailscale"

RUN apk add --no-cache ca-certificates iptables iproute2 ip6tables

COPY --from=tailscale ["/usr/local/bin/*","/usr/local/bin/"]
RUN mkdir /tailscale && ln -s /usr/local/bin/containerboot /tailscale/run.sh
ENTRYPOINT ["/usr/local/bin/tailscale"]

########################################

FROM --platform=$BUILDPLATFORM golang:1.26.5-trixie AS derp-build

WORKDIR /go/src

ARG APPVERSION
RUN git clone --single-branch --depth 1 --branch v${APPVERSION} https://github.com/tailscale/tailscale.git .

ENV CGO_ENABLED=0
RUN go mod download
RUN GOOS=linux GOARCH=amd64 go build -ldflags "-w -s -X tailscale.com/version.longStamp=v${APPVERSION}" -o dist/derper.linux.amd64 ./cmd/derper && \
    GOOS=linux GOARCH=arm64 go build -ldflags "-w -s -X tailscale.com/version.longStamp=v${APPVERSION}" -o dist/derper.linux.arm64 ./cmd/derper && \
    ./dist/derper.linux.`go env GOARCH` -version

########################################

FROM alpine:3.24 AS derp
LABEL org.opencontainers.image.description="The easiest, most secure way to use WireGuard and 2FA" \
      org.opencontainers.image.licenses="BSD 3-Clause License" \
      org.opencontainers.image.source="https://github.com/tailscale/tailscale"

WORKDIR /app

ARG TARGETARCH
COPY --from=derp-build ["/go/src/dist/derper.linux.${TARGETARCH}","/app/derper"]
