# syntax = docker/dockerfile:1.14
########################################
ARG APPVERSION
########################################

FROM --platform=$BUILDPLATFORM golang:1.22-bullseye AS build
RUN apt-get update && apt-get install -y git build-essential

WORKDIR /src

ARG APPVERSION
ENV APPVERSION=${APPVERSION}
RUN git clone --single-branch --depth 2 --branch release-4.20 https://github.com/openshift/cloud-provider-gcp.git .
RUN go mod edit -replace k8s.io/cloud-provider@v0.30.0=github.com/sergelogvinov/cloud-provider@nodelifecycle-${APPVERSION} && \
    go mod tidy && go mod vendor

ENV CGO_ENABLED=0 GOOS=linux
RUN GOARCH=amd64 go build -a -o /src/cloud-controller-manager-amd64 -ldflags="-w -s -X 'main.version=${APPVERSION}'" ./cmd/cloud-controller-manager && \
    GOARCH=arm64 go build -a -o /src/cloud-controller-manager-arm64 -ldflags="-w -s -X 'main.version=${APPVERSION}'" ./cmd/cloud-controller-manager && \
    ./cloud-controller-manager-`go env GOARCH` --version

########################################

FROM gcr.io/distroless/static:nonroot-${TARGETARCH} AS pkg
LABEL org.opencontainers.image.description="GCP Cloud controller manager" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.source="https://github.com/kubernetes-sigs/cloud-provider-azure"

ARG TARGETARCH
COPY --from=build /src/cloud-controller-manager-${TARGETARCH} /bin/gcp-cloud-controller-manager
WORKDIR /
ENTRYPOINT ["/bin/gcp-cloud-controller-manager"]
