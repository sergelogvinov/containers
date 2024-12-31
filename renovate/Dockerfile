# syntax = docker/dockerfile:1.11
########################################
ARG APPVERSION=39.86
########################################

FROM renovate/renovate:${APPVERSION} AS pkg

USER root

ENV HELMDOCSVERSION=1.14.2
ARG TARGETARCH
RUN cd /tmp && curl -L -O https://github.com/norwoodj/helm-docs/releases/download/v${HELMDOCSVERSION}/helm-docs_${HELMDOCSVERSION}_Linux_${TARGETARCH}.tar.gz && \
    tar -xvf helm-docs_1.14.2_Linux_${TARGETARCH}.tar.gz && \
    mv helm-docs /usr/local/bin/helm-docs && \
    chmod +x /usr/local/bin/helm-docs && \
    rm -rf /tmp/*

USER ubuntu
