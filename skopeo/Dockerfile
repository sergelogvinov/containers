# syntax = docker/dockerfile:1.11
########################################
ARG APPVERSION
########################################

FROM --platform=$BUILDPLATFORM golang:1.22-bullseye AS skopeo

RUN apt-get update && apt-get install -y git build-essential

WORKDIR /go/src/

ARG APPVERSION
RUN git clone --single-branch --depth 2 --branch v${APPVERSION} https://github.com/containers/skopeo .

ENV EXTRA_LDFLAGS="-s -w" CGO_ENABLED=0
RUN make bin/skopeo.linux.amd64 bin/skopeo.linux.arm64

########################################

FROM alpine:3.21 AS pkg
LABEL org.opencontainers.image.description="Copying an image from and to various storage mechanisms" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.source="https://github.com/containers/skopeo"

ARG TARGETARCH
COPY --from=skopeo ["/go/src/default-policy.json","/etc/containers/policy.json"]
COPY --from=skopeo ["/go/src/bin/skopeo.linux.${TARGETARCH}","/usr/bin/skopeo"]

ENTRYPOINT ["/usr/bin/skopeo"]
