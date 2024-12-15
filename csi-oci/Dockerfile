# syntax = docker/dockerfile:1.11
########################################
ARG APPVERSION
########################################

FROM --platform=$BUILDPLATFORM golang:1.22.9-bullseye AS build
RUN apt-get update && apt-get install -y git build-essential

WORKDIR /src

ARG APPVERSION
ENV APPVERSION=${APPVERSION}
RUN git clone --single-branch --depth 2 --branch release-${APPVERSION}-talos https://github.com/sergelogvinov/oci-cloud-controller-manager.git .

ENV CGO_ENABLED=0 GOOS=linux VERSION=v${APPVERSION}.0 COMPONENT="oci-csi-controller-driver oci-csi-node-driver"
RUN make build ARCH=amd64 && \
    mv dist/oci-csi-controller-driver oci-csi-controller-driver-amd64 && \
    mv dist/oci-csi-node-driver oci-csi-node-driver-amd64 && \
    make build ARCH=arm64 && \
    mv dist/oci-csi-controller-driver oci-csi-controller-driver-arm64 && \
    mv dist/oci-csi-node-driver oci-csi-node-driver-arm64

########################################

FROM ghcr.io/oracle/cloud-provider-oci:v${APPVERSION}.0 AS pkg

ARG TARGETARCH
COPY --from=build /src/oci-csi-controller-driver-${TARGETARCH} /usr/local/bin/oci-csi-controller-driver
COPY --from=build /src/oci-csi-node-driver-${TARGETARCH} /usr/local/bin/oci-csi-node-driver
