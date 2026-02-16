# syntax = docker/dockerfile:1.21
########################################
ARG APPVERSION
########################################

FROM --platform=$BUILDPLATFORM golang:1.22-bullseye AS build
RUN apt-get update && apt-get install -y git build-essential

WORKDIR /src

ARG APPVERSION
ENV APPVERSION=${APPVERSION}
RUN git clone --single-branch --depth 2 --branch release-0.31 https://github.com/scaleway/scaleway-cloud-controller-manager.git .
RUN go mod edit -replace k8s.io/cloud-provider@v0.31.0=github.com/sergelogvinov/cloud-provider@nodelifecycle-${APPVERSION} && \
    go mod tidy

ENV CGO_ENABLED=0 GOOS=linux
RUN GOARCH=amd64 go build -a -o /src/scaleway-cloud-controller-manager-amd64 -ldflags "-w -s -X github.com/scaleway/scaleway-cloud-controller-manager/scaleway.ccmVersion=${APPVERSION}" ./cmd/scaleway-cloud-controller-manager && \
    GOARCH=arm64 go build -a -o /src/scaleway-cloud-controller-manager-arm64 -ldflags "-w -s -X github.com/scaleway/scaleway-cloud-controller-manager/scaleway.ccmVersion=${APPVERSION}" ./cmd/scaleway-cloud-controller-manager && \
    ./scaleway-cloud-controller-manager-`go env GOARCH` --version

########################################

FROM gcr.io/distroless/static:nonroot-${TARGETARCH} AS pkg
LABEL org.opencontainers.image.description="Scaleway Cloud controller manager" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.source="https://github.com/scaleway/scaleway-cloud-controller-manager"

ARG TARGETARCH
COPY --from=build /src/scaleway-cloud-controller-manager-${TARGETARCH} /scaleway-cloud-controller-manager
WORKDIR /
ENTRYPOINT ["/scaleway-cloud-controller-manager"]
