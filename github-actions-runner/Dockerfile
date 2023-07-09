# syntax = docker/dockerfile:1.4
########################################
ARG APPVERSION
########################################

FROM golang:1.18-bullseye AS helm

WORKDIR /go/src/
RUN git clone --single-branch --depth 2 --branch hooks-logs https://github.com/sergelogvinov/helm.git .
RUN make

########################################

FROM ghcr.io/actions/actions-runner:${APPVERSION} AS pkg

USER root

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && apt-get dist-upgrade -y && \
    apt-get install -y --no-install-recommends software-properties-common procps vim-tiny \
        curl wget make zip rsync git \
        ansible ansible-lint yamllint jq && \
    apt-get install -y python3-boto python3-jmespath && \
    ln -s /usr/bin/python3 /usr/bin/python

RUN install -m 0775 -o runner -g runner -d /app && \
    install -m 0775 -o runner -g runner -d /home/github -d /home/github/.ansible -d /home/github/builds && \
    install -m 0775 -o runner -g runner -d /home/runner -d /home/runner/.ansible

# https://hub.docker.com/_/docker/tags
COPY --from=docker:23.0.6-cli /usr/local/libexec/docker/cli-plugins/docker-compose /usr/local/libexec/docker/cli-plugins/docker-compose
COPY --from=docker/buildx-bin:0.10.4 /buildx /usr/local/libexec/docker/cli-plugins/docker-buildx
COPY --from=ghcr.io/sergelogvinov/skopeo:1.13.0 /usr/bin/skopeo /usr/bin/skopeo
COPY --from=ghcr.io/sergelogvinov/skopeo:1.13.0 /etc/containers/ /etc/containers/
COPY --from=ghcr.io/aquasecurity/trivy:0.42.1 /usr/local/bin/trivy /usr/local/bin/trivy
COPY --from=ghcr.io/sergelogvinov/reviewdog:0.14.2 /usr/bin/reviewdog /usr/bin/reviewdog

COPY --from=bitnami/kubectl:1.24.15 /opt/bitnami/kubectl/bin/kubectl /usr/local/bin/kubectl
COPY --from=alpine/helm:3.12.1 /usr/bin/helm /usr/bin/helm
COPY --from=ghcr.io/sergelogvinov/sops:3.7.3  /usr/bin/sops /usr/bin/sops
COPY --from=ghcr.io/sergelogvinov/vals:0.25.0 /usr/bin/vals /usr/bin/vals

# helm hooks error log https://github.com/helm/helm/pull/11228
COPY --from=helm --chown=root:root /go/src/bin/helm /usr/bin/helm

COPY --from=amazon/aws-cli:2.11.19 /usr/local/aws-cli /usr/local/aws-cli
RUN ln -s /usr/local/aws-cli/v2/current/bin/aws /usr/local/bin/aws

RUN apt-get update && apt-get install -y apt-transport-https ca-certificates gnupg && \
    echo "deb https://packages.cloud.google.com/apt cloud-sdk main" > /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-get update && apt-get install -y google-cloud-sdk

ENV HELM_DATA_HOME=/usr/local/share/helm
RUN helm plugin install https://github.com/jkroepke/helm-secrets --version v3.15.0 && \
    helm repo add bitnami  https://charts.bitnami.com/bitnami && \
    helm repo add sinextra https://helm-charts.sinextra.dev && \
    helm repo update

USER runner
WORKDIR /app

ENV RUNNER_WORK_FOLDER=/home/github/builds ACTIONS_RUNNER_PRINT_LOG_TO_STDOUT=0
COPY etc/ansible.cfg /etc/ansible/ansible.cfg

ENTRYPOINT [ "/home/runner/run.sh" ]
