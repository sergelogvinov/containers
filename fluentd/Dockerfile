# syntax = docker/dockerfile:1.4
########################################
ARG APPVERSION
########################################

FROM fluent/fluentd:v${APPVERSION}-debian-1.0 AS pkg
LABEL org.opencontainers.image.description="Fluentd with modules"
LABEL org.opencontainers.image.licenses=MIT

USER root
WORKDIR /fluentd/etc

RUN gem install \
    fluent-plugin-record-modifier \
    fluent-plugin-anonymizer \
    fluent-plugin-prometheus \
    fluent-plugin-grafana-loki

COPY --chown=fluent:fluent ["conf/", "/fluentd/etc/"]

USER fluent
