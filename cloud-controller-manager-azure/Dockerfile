# syntax = docker/dockerfile:1.11
########################################
ARG APPVERSION
########################################

FROM --platform=$BUILDPLATFORM golang:1.23-bullseye AS build
RUN apt-get update && apt-get install -y git build-essential

WORKDIR /src

ARG APPVERSION
ENV APPVERSION=${APPVERSION}
RUN git clone --single-branch --depth 2 --branch multi-regionl-only-openstack https://github.com/sergelogvinov/cloud-provider-openstack.git .
# RUN go mod edit -replace k8s.io/cloud-provider@v0.31.3=github.com/sergelogvinov/cloud-provider@nodelifecycle-${APPVERSION} && \
#     go mod tidy

ENV CGO_ENABLED=0 GOOS=linux VERSION=${APPVERSION}
RUN make build BUILD_CMDS=openstack-cloud-controller-manager GOARCH=amd64 && \
    mv openstack-cloud-controller-manager openstack-cloud-controller-manager-amd64 && \
    make build BUILD_CMDS=openstack-cloud-controller-manager GOARCH=arm64 && \
    mv openstack-cloud-controller-manager openstack-cloud-controller-manager-arm64 && \
    ./openstack-cloud-controller-manager-`go env GOARCH` --version

########################################

FROM gcr.io/distroless/static:nonroot-${TARGETARCH} AS pkg

ARG TARGETARCH
COPY --from=build /src/openstack-cloud-controller-manager-${TARGETARCH} /openstack-cloud-controller-manager
WORKDIR /
ENTRYPOINT ["/openstack-cloud-controller-manager"]
