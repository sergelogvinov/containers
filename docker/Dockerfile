# syntax = docker/dockerfile:1.4
########################################

FROM alpine:3.17 AS pkg
LABEL org.opencontainers.image.description="Docker build machine"
LABEL org.opencontainers.image.licenses=MIT

ARG APPVERSION
RUN apk --update add "docker>${APPVERSION}" device-mapper && \
    mkdir /root/.docker && \
    ln -s /etc/docker-tlscerts/ca.crt   /root/.docker/ca.pem    && \
    ln -s /etc/docker-tlscerts/tls.crt  /root/.docker/cert.pem  && \
    ln -s /etc/docker-tlscerts/tls.key  /root/.docker/key.pem

ENV DOCKER_HOST=tcp://127.0.0.1:2376

VOLUME ["/var/lib/docker"]
ENTRYPOINT ["/usr/bin/dockerd","-H","tcp://0.0.0.0:2376"]
