# syntax = docker/dockerfile:1.11
########################################
ARG APPVERSION
########################################

FROM --platform=$BUILDPLATFORM golang:1.23-bullseye AS build
RUN apt-get update && apt-get install -y git build-essential

WORKDIR /src

ARG APPVERSION
ENV APPVERSION=${APPVERSION}
RUN git clone --single-branch --depth 2 --branch release-${APPVERSION} https://github.com/kubernetes-sigs/cloud-provider-azure.git .
RUN go mod edit -replace k8s.io/cloud-provider@v0.31.3=github.com/sergelogvinov/cloud-provider@nodelifecycle-${APPVERSION} && \
    go mod tidy && go mod vendor

ENV CGO_ENABLED=0 GOOS=linux
RUN GOARCH=amd64 go build -a -o /src/cloud-controller-manager-amd64 -ldflags '-s -w -X sigs.k8s.io/cloud-provider-azure/pkg/version.gitVersion=${APPVERSION}' ./cmd/cloud-controller-manager && \
    GOARCH=arm64 go build -a -o /src/cloud-controller-manager-arm64 -ldflags '-s -w -X sigs.k8s.io/cloud-provider-azure/pkg/version.gitVersion=${APPVERSION}' ./cmd/cloud-controller-manager && \
    ./cloud-controller-manager-`go env GOARCH` --version

########################################

FROM gcr.io/distroless/static:nonroot-${TARGETARCH} AS pkg
LABEL org.opencontainers.image.description="Azure controller manager" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.source="https://github.com/kubernetes-sigs/cloud-provider-azure"

ARG TARGETARCH
COPY --from=build /src/cloud-controller-manager-${TARGETARCH} /cloud-controller-manager
WORKDIR /
ENTRYPOINT ["/cloud-controller-manager"]