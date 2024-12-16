# syntax = docker/dockerfile:1.11
########################################
ARG APPVERSION
########################################

FROM --platform=$BUILDPLATFORM golang:1.22-bullseye AS build
RUN apt-get update && apt-get install -y git build-essential

WORKDIR /src

ARG APPVERSION
ENV APPVERSION=${APPVERSION}
RUN git clone --single-branch --depth 2 --branch v1.21.0 https://github.com/hetznercloud/hcloud-cloud-controller-manager.git .
RUN go mod edit -replace k8s.io/cloud-provider@v0.31.3=github.com/sergelogvinov/cloud-provider@nodelifecycle-${APPVERSION} && \
    go mod tidy

ENV CGO_ENABLED=0 GOOS=linux
RUN GOARCH=amd64 go build -a -o /src/cloud-controller-manager-amd64 -ldflags '-s -w -X github.com/hetznercloud/hcloud-cloud-controller-manager/hcloud.providerVersion=${APPVERSION}' . && \
    GOARCH=arm64 go build -a -o /src/cloud-controller-manager-arm64 -ldflags '-s -w -X github.com/hetznercloud/hcloud-cloud-controller-manager/hcloud.providerVersion=${APPVERSION}' . && \
    ./cloud-controller-manager-`go env GOARCH` --version

########################################

FROM --platform=${TARGETARCH} scratch AS pkg
LABEL org.opencontainers.image.description="Hetzner cloud controller manager" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.source="https://github.com/hetznercloud/hcloud-cloud-controller-manager"

COPY --from=gcr.io/distroless/static-debian12:nonroot . .
ARG TARGETARCH
COPY --from=build /src/cloud-controller-manager-${TARGETARCH} /bin/hcloud-cloud-controller-manager
WORKDIR /
ENTRYPOINT ["/bin/hcloud-cloud-controller-manager"]