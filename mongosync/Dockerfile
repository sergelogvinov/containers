# syntax = docker/dockerfile:1.21
########################################
ARG APPVERSION=1.15.0
########################################

FROM --platform=$BUILDPLATFORM ubuntu:24.04 AS archive

RUN apt-get update && apt-get install --no-install-recommends -y ca-certificates wget
ARG APPVERSION

WORKDIR /src
RUN wget https://fastdl.mongodb.org/tools/mongosync/mongosync-ubuntu2404-x86_64-${APPVERSION}.tgz  -O /src/mongosync-amd64.tgz

RUN tar -xzf /src/mongosync-amd64.tgz && mkdir -p /src/amd64/bin && \
    mv mongosync-ubuntu2404-x86_64-${APPVERSION}/bin/*  /src/amd64/bin/ && \
    mkdir -p /src/arm64/bin && cp /src/amd64/bin/* /src/arm64/bin/

########################################

FROM ubuntu:24.04 AS pkg
ARG APPVERSION=1.15.0
LABEL org.opencontainers.image.description="MongoSync" \
      org.opencontainers.image.documentation="https://www.mongodb.com/docs/cluster-to-cluster-sync" \
      org.opencontainers.image.version=${APPVERSION}

RUN apt-get update && apt-get install --no-install-recommends -y ca-certificates libkrb5-3 curl jq

ARG TARGETARCH
COPY --from=archive --chown=0:0 ["/src/${TARGETARCH}/bin","/usr/local/bin"]

USER 34
ENTRYPOINT ["/usr/local/bin/mongosync"]
