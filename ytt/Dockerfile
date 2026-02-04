# syntax = docker/dockerfile:1.21
########################################
ARG APPVERSION=0.53.0
########################################

FROM --platform=$BUILDPLATFORM alpine:3.23 AS ytt

WORKDIR /src/ytt

ARG APPVERSION
RUN apk add --no-cache curl cosign
RUN curl -LO https://github.com/carvel-dev/ytt/releases/download/v${APPVERSION}/checksums.txt && \
    curl -LO https://github.com/carvel-dev/ytt/releases/download/v${APPVERSION}/checksums.txt.pem && \
    curl -LO https://github.com/carvel-dev/ytt/releases/download/v${APPVERSION}/checksums.txt.sig

RUN cosign verify-blob checksums.txt \
    --certificate checksums.txt.pem \
    --signature checksums.txt.sig \
    --certificate-identity-regexp=https://github.com/carvel-dev \
    --certificate-oidc-issuer=https://token.actions.githubusercontent.com

RUN curl -LO https://github.com/carvel-dev/ytt/releases/download/v${APPVERSION}/ytt-linux-amd64 && \
    curl -LO https://github.com/carvel-dev/ytt/releases/download/v${APPVERSION}/ytt-linux-arm64 && \
    grep -e "ytt-linux-a" checksums.txt | sha256sum -c -

########################################

FROM alpine:3.23 AS pkg

LABEL org.opencontainers.image.description="YTT is a templating tool that understands YAML structure." \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.source="https://github.com/carvel-dev/ytt"

ARG TARGETARCH
COPY --from=ytt ["/src/ytt/ytt-linux-${TARGETARCH}","/usr/local/bin/ytt"]
