# syntax = docker/dockerfile:1.4
########################################
ARG APPVERSION
########################################

FROM golang:1.21-bullseye AS helm

WORKDIR /go/src/
RUN git clone --single-branch --depth 2 --branch release-3.13.3-logs https://github.com/sergelogvinov/helm.git .
RUN make

########################################

FROM golang:1.19-bullseye AS git-chglog

WORKDIR /go/src/
RUN git clone --single-branch --depth 2 --branch v0.15.4 https://github.com/git-chglog/git-chglog .
RUN make build && \
    ./git-chglog --version && \
    cp git-chglog /usr/local/bin/git-chglog

########################################

FROM ghcr.io/actions/actions-runner:${APPVERSION} AS actions-runner

########################################

FROM scratch AS base
LABEL org.opencontainers.image.description="GitHub actions runner" \
      org.opencontainers.image.source="https://github.com/sergelogvinov/containers/tree/main/github-actions-runner"

COPY --from=actions-runner . .
USER root

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && apt-get dist-upgrade -y && \
    apt-get install -y --no-install-recommends procps vim-tiny \
        curl wget make zip rsync git \
        ansible ansible-lint yamllint jq && \
    apt-get install -y python3-boto python3-jmespath && \
    ln -s /usr/bin/python3 /usr/bin/python

RUN install -m 0775 -o runner -g runner -d /app && \
    install -m 0775 -o runner -g runner -d /home/github -d /home/github/.ansible -d /home/github/builds && \
    install -m 0775 -o runner -g runner -d /home/runner -d /home/runner/.ansible

# https://hub.docker.com/_/docker/tags
COPY --from=docker:24.0.7-cli /usr/local/libexec/docker/cli-plugins/docker-compose /usr/local/libexec/docker/cli-plugins/docker-compose
COPY --from=docker/buildx-bin:0.12.0 /buildx /usr/local/libexec/docker/cli-plugins/docker-buildx
COPY --from=ghcr.io/sergelogvinov/skopeo:1.13 /usr/bin/skopeo /usr/bin/skopeo
COPY --from=ghcr.io/sergelogvinov/skopeo:1.13 /etc/containers/ /etc/containers/
COPY --from=ghcr.io/aquasecurity/trivy:0.47.0 /usr/local/bin/trivy /usr/local/bin/trivy
COPY --from=ghcr.io/sergelogvinov/reviewdog:0.14.2 /usr/bin/reviewdog /usr/bin/reviewdog
COPY --from=git-chglog /usr/local/bin/git-chglog /usr/bin/git-chglog

COPY --from=bitnami/kubectl:1.27.8 /opt/bitnami/kubectl/bin/kubectl /usr/local/bin/kubectl
COPY --from=alpine/helm:3.13.2 /usr/bin/helm /usr/bin/helm
COPY --from=ghcr.io/getsops/sops:v3.8.1-alpine /usr/local/bin/sops /usr/bin/sops
COPY --from=ghcr.io/sergelogvinov/vals:0.28.0 /usr/bin/vals /usr/bin/vals
COPY --from=ghcr.io/yannh/kubeconform:v0.6.4 /kubeconform /usr/bin/kubeconform
COPY --from=minio/mc:RELEASE.2023-10-30T18-43-32Z /usr/bin/mc /usr/bin/mc

# helm hooks error log https://github.com/helm/helm/pull/11228 https://github.com/helm/helm/pull/10309
COPY --from=helm --chown=root:root /go/src/bin/helm /usr/bin/helm

ENV HELM_DATA_HOME=/usr/local/share/helm
RUN helm plugin install https://github.com/jkroepke/helm-secrets --version v4.5.1 && \
    helm repo add bitnami  https://charts.bitnami.com/bitnami && \
    helm repo add sinextra https://helm-charts.sinextra.dev && \
    helm repo update

ENV RUNNER_WORK_FOLDER=/home/github/builds ACTIONS_RUNNER_PRINT_LOG_TO_STDOUT=0
ENV BUILDKIT_PROGRESS=plain

COPY etc/ansible.cfg /etc/ansible/ansible.cfg
COPY scripts/ /

ENTRYPOINT [ "/home/runner/run.sh" ]

########################################

FROM base AS pkg

USER runner
WORKDIR /app

########################################

FROM base AS aws

COPY --from=amazon/aws-cli:2.12.7 /usr/local/aws-cli /usr/local/aws-cli
RUN ln -s /usr/local/aws-cli/v2/current/bin/aws /usr/local/bin/aws

USER runner
WORKDIR /app

########################################

FROM base AS gcp

RUN apt-get update && apt-get install -y apt-transport-https ca-certificates gnupg && \
    echo "deb https://packages.cloud.google.com/apt cloud-sdk main" > /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-get update && apt-get install -y google-cloud-sdk

USER runner
WORKDIR /app
