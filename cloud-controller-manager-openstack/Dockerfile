# syntax = docker/dockerfile:1.11
########################################
ARG APPVERSION
########################################

FROM --platform=$BUILDPLATFORM golang:1.22.2-bullseye AS build
RUN apt-get update && apt-get install -y git build-essential

WORKDIR /src

ARG APPVERSION
ENV APPVERSION=${APPVERSION}
RUN git clone --single-branch --depth 2 --branch multi-regionl-only-openstack https://github.com/sergelogvinov/cloud-provider-openstack.git .
RUN go mod edit -replace k8s.io/cloud-provider@v0.31.3=github.com/sergelogvinov/cloud-provider@nodelifecycle-${APPVERSION} && \
    go mod tidy

ENV CGO_ENABLED=0 GOOS=linux VERSION=v${APPVERSION}.0
RUN make build BUILD_CMDS=openstack-cloud-controller-manager GOARCH=amd64 && \
    mv openstack-cloud-controller-manager openstack-cloud-controller-manager-amd64 && \
    make build BUILD_CMDS=openstack-cloud-controller-manager GOARCH=arm64 && \
    mv openstack-cloud-controller-manager openstack-cloud-controller-manager-arm64 && \
    ./openstack-cloud-controller-manager-`go env GOARCH` --version

########################################

FROM gcr.io/distroless/static:nonroot-${TARGETARCH} AS pkg
LABEL org.opencontainers.image.description="Openstack controller manager" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.source="https://github.com/sergelogvinov/cloud-provider-openstack"

ARG TARGETARCH
COPY --from=build /src/openstack-cloud-controller-manager-${TARGETARCH} /bin/openstack-cloud-controller-manager
WORKDIR /
CMD ["/bin/openstack-cloud-controller-manager"]
