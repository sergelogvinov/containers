# syntax = docker/dockerfile:1.16
########################################
ARG APPVERSION=3.2.1-alpine3.22
########################################

FROM haproxy:${APPVERSION} AS pkg
LABEL org.opencontainers.image.description="Haproxy with net-bind flag" \
      org.opencontainers.image.documentation="https://www.haproxy.org" \
      org.opencontainers.image.source="https://github.com/sergelogvinov/containers/tree/haproxy/Dockerfile"

USER root
RUN apk add libcap
RUN setcap    cap_net_bind_service=+ep /usr/local/sbin/haproxy && \
    setcap -v cap_net_bind_service=+ep /usr/local/sbin/haproxy

COPY ["haproxy.cfg","/etc/haproxy/haproxy.cfg"]

USER haproxy
ENTRYPOINT ["/usr/local/sbin/haproxy"]
CMD ["-f", "/etc/haproxy/haproxy.cfg"]
