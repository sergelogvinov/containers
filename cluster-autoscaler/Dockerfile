# syntax = docker/dockerfile:1.11
########################################
ARG APPVERSION
########################################

FROM --platform=$BUILDPLATFORM golang:1.23-bullseye AS build
RUN apt-get update && apt-get install -y git build-essential

WORKDIR /src

ARG APPVERSION
ENV APPVERSION=${APPVERSION}
RUN git clone --single-branch --depth 2 --branch cluster-autoscaler-release-${APPVERSION}-patch https://github.com/sergelogvinov/autoscaler.git .

ENV CGO_ENABLED=0 BUILD_TAGS=${APPVERSION}
RUN cd /src/cluster-autoscaler && make build-arch-amd64 build-arch-arm64

########################################

FROM gcr.io/distroless/static:nonroot-${TARGETARCH} AS pkg

ARG TARGETARCH
COPY --from=build /src/cluster-autoscaler/cluster-autoscaler-${TARGETARCH} /cluster-autoscaler
WORKDIR /
CMD ["/cluster-autoscaler"]
