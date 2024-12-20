# syntax = docker/dockerfile:1.11
########################################
ARG APPVERSION=1.17.1
########################################

FROM fluent/fluentd:v${APPVERSION}-debian-1.1 AS pkg
LABEL org.opencontainers.image.description="Fluentd with modules" \
      org.opencontainers.image.licenses="MIT"

USER root
WORKDIR /fluentd/etc

RUN gem install \
    fluent-plugin-record-modifier \
    fluent-plugin-anonymizer \
    fluent-plugin-prometheus \
    fluent-plugin-grafana-loki \
    fluent-plugin-s3

COPY --chown=fluent:fluent ["conf/", "/fluentd/etc/"]

USER fluent

########################################

FROM pkg AS clickhouse
LABEL org.opencontainers.image.description="Fluentd with clickhouse"

USER root
COPY scripts/clickhouse-push.sh /usr/bin/clickhouse-push.sh
COPY --from=clickhouse/clickhouse-server:24.12 /usr/bin/clickhouse /usr/bin/clickhouse
RUN ln -s /usr/bin/clickhouse /usr/bin/clickhouse-client

USER fluent

########################################

FROM pkg AS logtail
LABEL org.opencontainers.image.description="Fluentd with logtail"

USER root
RUN gem install \
    fluent-plugin-logtail

USER fluent
