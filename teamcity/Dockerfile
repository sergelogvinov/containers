# syntax = docker/dockerfile:1.6
########################################
ARG APPVERSION
########################################

FROM jetbrains/teamcity-server:${APPVERSION} AS pkg
LABEL org.opencontainers.image.description="Teamcity" \
      org.opencontainers.image.documentation="https://hub.docker.com/r/jetbrains/teamcity-server" \
      org.opencontainers.image.version=${APPVERSION}

USER root
RUN curl -LfsSo /opt/teamcity/webapps/ROOT/WEB-INF/lib/postgresql-42.7.4.jar https://jdbc.postgresql.org/download/postgresql-42.7.4.jar && \
    echo "ef7e9be503b5c6243697d628fb196cad /opt/teamcity/webapps/ROOT/WEB-INF/lib/postgresql-42.7.4.jar" | md5sum -c - && \
    curl -LfsSo /opt/teamcity/webapps/ROOT/WEB-INF/plugins/teamcity-oauth-1.1.9.zip https://github.com/pwielgolaski/teamcity-oauth/releases/download/teamcity-oauth-1.1.9/teamcity-oauth-1.1.9.zip && \
    echo "54397b7e08831e179e12d328e240ee15 /opt/teamcity/webapps/ROOT/WEB-INF/plugins/teamcity-oauth-1.1.9.zip" | md5sum -c -

RUN install -o tcuser -g tcuser -d /data -d /home/tcuser
COPY --chown=tcuser:tcuser config/server.xml /opt/teamcity/conf/server.xml

USER tcuser
WORKDIR /opt/teamcity
CMD ["/opt/teamcity/bin/teamcity-server.sh","run"]

########################################

FROM jetbrains/teamcity-minimal-agent:${APPVERSION} AS agent
LABEL org.opencontainers.image.description="Teamcity Agent" \
      org.opencontainers.image.documentation="https://hub.docker.com/r/jetbrains/teamcity-minimal-agent" \
      org.opencontainers.image.version=${APPVERSION}

USER root
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y software-properties-common vim-tiny curl wget git make zip rsync docker.io && \
    apt-get install -y ansible python3-pip python3-boto && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /home/buildagent/conf /home/buildagent/.ansible && \
    chown -R buildagent.buildagent /opt/buildagent /home/buildagent

# https://hub.docker.com/_/docker/tags
COPY --from=docker:25.0.5-cli /usr/local/libexec/docker/cli-plugins/docker-compose /usr/local/libexec/docker/cli-plugins/docker-compose
COPY --from=docker/buildx-bin:0.13.1 /buildx /usr/local/libexec/docker/cli-plugins/docker-buildx
COPY --from=ghcr.io/sergelogvinov/skopeo:1.15 /usr/bin/skopeo /usr/bin/skopeo
COPY --from=ghcr.io/sergelogvinov/skopeo:1.15 /etc/containers/ /etc/containers/
COPY --from=ghcr.io/aquasecurity/trivy:0.55.2 /usr/local/bin/trivy /usr/local/bin/trivy
COPY --from=ghcr.io/sergelogvinov/reviewdog:0.17.2 /usr/bin/reviewdog /usr/bin/reviewdog
COPY --from=ghcr.io/sergelogvinov/git-chglog:0.15.4 /usr/local/bin/git-chglog /usr/bin/git-chglog

COPY --from=bitnami/kubectl:1.31 /opt/bitnami/kubectl/bin/kubectl /usr/local/bin/kubectl
COPY --from=alpine/helm:3.13.3 /usr/bin/helm /usr/bin/helm
COPY --from=ghcr.io/getsops/sops:v3.9.0-alpine /usr/local/bin/sops /usr/bin/sops
COPY --from=ghcr.io/sergelogvinov/vals:0.36.0 /usr/bin/vals /usr/bin/vals
COPY --from=ghcr.io/yannh/kubeconform:v0.6.7 /kubeconform /usr/bin/kubeconform
COPY --from=minio/mc:RELEASE.2024-01-16T16-06-34Z /usr/bin/mc /usr/bin/mc

# helm hooks error log https://github.com/helm/helm/pull/11228 https://github.com/helm/helm/pull/10309
COPY --from=ghcr.io/sergelogvinov/helm:3.13.3 --chown=root:root /usr/bin/helm /usr/bin/helm

USER buildagent

WORKDIR /home/buildagent
COPY --chown=root:root etc/ /etc/

RUN helm plugin install https://github.com/jkroepke/helm-secrets --version v4.5.1 && \
    helm repo add bitnami  https://charts.bitnami.com/bitnami && \
    helm repo add sinextra https://helm-charts.sinextra.dev && \
    helm repo update

ENV CONFIG_FILE=/home/buildagent/conf/buildAgent.properties
