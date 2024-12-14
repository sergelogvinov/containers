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
RUN go mod edit -replace k8s.io/cloud-provider@v0.30.6=github.com/sergelogvinov/cloud-provider@nodelifecycle-${APPVERSION} && \
    go mod tidy && go mod vendor

ENV CGO_ENABLED=0 GOOS=linux VERSION=v${APPVERSION}.0
RUN make build COMPONENT=oci-cloud-controller-manager GOARCH=amd64 && \
    mv dist/oci-cloud-controller-manager oci-cloud-controller-manager-amd64 && \
    make build COMPONENT=oci-cloud-controller-manager GOARCH=amd64 && \
    mv dist/oci-cloud-controller-manager oci-cloud-controller-manager-arm64 && \
    ./oci-cloud-controller-manager-`go env GOARCH` --version

########################################

FROM gcr.io/distroless/static:nonroot-${TARGETARCH} AS pkg
LABEL org.opencontainers.image.description="Oracle controller manager" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.source="https://github.com/oracle/oci-cloud-controller-manager"

ARG TARGETARCH
COPY --from=build /src/oci-cloud-controller-manager-${TARGETARCH} /usr/local/bin/oci-cloud-controller-manager
WORKDIR /
ENTRYPOINT ["/usr/local/bin/oci-cloud-controller-manager"]
