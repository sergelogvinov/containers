# syntax = docker/dockerfile:1.11
########################################
ARG APPVERSION=2.322.0
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
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN wget https://cli.github.com/packages/githubcli-archive-keyring.gpg -O /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list && \
    apt-get update && apt-get install -y gh && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN install -m 0775 -o runner -g runner -d /app && \
    install -m 0775 -o runner -g runner -d /home/github -d /home/github/.ansible -d /home/github/builds && \
    install -m 0775 -o runner -g runner -d /home/runner -d /home/runner/.ansible

# https://hub.docker.com/_/docker/tags
COPY --from=docker:27.5.0-cli /usr/local/libexec/docker/cli-plugins/docker-compose /usr/local/lib/docker/cli-plugins/docker-compose
# COPY --from=docker/buildx-bin:0.15.0 /buildx /usr/local/lib/docker/cli-plugins/docker-buildx
COPY --from=ghcr.io/sergelogvinov/skopeo:1.15 /usr/bin/skopeo /usr/bin/skopeo
COPY --from=ghcr.io/sergelogvinov/skopeo:1.15 /etc/containers/ /etc/containers/
COPY --from=ghcr.io/aquasecurity/trivy:0.58.2 /usr/local/bin/trivy /usr/local/bin/trivy
COPY --from=ghcr.io/sergelogvinov/reviewdog:0.20.3 /usr/bin/reviewdog /usr/bin/reviewdog
COPY --from=ghcr.io/sergelogvinov/git-chglog:0.15.4 /usr/local/bin/git-chglog /usr/bin/git-chglog

COPY --from=bitnami/kubectl:1.31.4 /opt/bitnami/kubectl/bin/kubectl /usr/local/bin/kubectl
COPY --from=alpine/helm:3.16.4 /usr/bin/helm /usr/bin/helm
COPY --from=ghcr.io/getsops/sops:v3.9.4-alpine /usr/local/bin/sops /usr/bin/sops
COPY --from=ghcr.io/sergelogvinov/vals:0.39.0 /usr/bin/vals /usr/bin/vals
COPY --from=ghcr.io/yannh/kubeconform:v0.6.7 /kubeconform /usr/bin/kubeconform
COPY --from=minio/mc:RELEASE.2024-01-16T16-06-34Z /usr/bin/mc /usr/bin/mc

# helm hooks error log https://github.com/helm/helm/pull/11228 https://github.com/helm/helm/pull/10309
COPY --from=ghcr.io/sergelogvinov/helm:3.13.3 --chown=root:root /usr/bin/helm /usr/bin/helm

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

COPY --from=amazon/aws-cli:2.22.3 /usr/local/aws-cli /usr/local/aws-cli
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
