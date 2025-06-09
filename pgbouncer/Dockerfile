# syntax = docker/dockerfile:1.16
########################################
ARG APPVERSION=16
########################################

FROM postgres:${APPVERSION}-bookworm AS pkg
LABEL org.opencontainers.image.description="PGBouncer" \
      org.opencontainers.image.licenses="MIT"

RUN apt-get update -y && apt-get install -y --no-install-recommends pgbouncer && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

USER postgres
ENTRYPOINT ["/usr/sbin/pgbouncer","-u","postgres","/etc/pgbouncer/pgbouncer.ini"]
