# syntax = docker/dockerfile:1.11
########################################
ARG APPVERSION=39.135
########################################

FROM --platform=$BUILDPLATFORM ubuntu:24.04 AS archive

RUN apt-get update && apt-get install --no-install-recommends -y ca-certificates wget

WORKDIR /src
ENV HELMDOCSVERSION=1.14.2
RUN wget https://github.com/norwoodj/helm-docs/releases/download/v${HELMDOCSVERSION}/helm-docs_${HELMDOCSVERSION}_Linux_x86_64.tar.gz -O /src/helm-docs-amd64.tar.gz && \
    wget https://github.com/norwoodj/helm-docs/releases/download/v${HELMDOCSVERSION}/helm-docs_${HELMDOCSVERSION}_Linux_arm64.tar.gz  -O /src/helm-docs-arm64.tar.gz

RUN tar -xvf helm-docs-amd64.tar.gz && \
    mv helm-docs helm-docs-amd64 && \
    tar -xvf helm-docs-arm64.tar.gz && \
    mv helm-docs helm-docs-arm64

########################################

FROM renovate/renovate:${APPVERSION} AS pkg

ARG TARGETARCH
COPY --from=archive --chown=0:0 ["/src/helm-docs-${TARGETARCH}","/usr/local/bin/helm-docs"]
