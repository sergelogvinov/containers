# syntax = docker/dockerfile:1.11
########################################
ARG APPVERSION
########################################

FROM postgres:bookworm AS pkg
LABEL org.opencontainers.image.description="pgBadger" \
      org.opencontainers.image.licenses="PostgreSQL Licence"

ARG APPVERSION
RUN apt-get update -y && apt-get install -y --no-install-recommends pgbadger && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

USER postgres
ENTRYPOINT ["/usr/bin/pgbadger"]
