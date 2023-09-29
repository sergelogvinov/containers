# syntax = docker/dockerfile:1.4
########################################
ARG APPVERSION
########################################

FROM alpine:3.18 AS pkg
LABEL org.opencontainers.image.description="Curl with utils" \
      org.opencontainers.image.licenses="MIT"

RUN apk add jq curl
