# syntax = docker/dockerfile:1.11
########################################
ARG APPVERSION=8.5.0
########################################

FROM alpine:3.21 AS pkg
LABEL org.opencontainers.image.description="Curl with utils" \
      org.opencontainers.image.licenses="MIT"

RUN apk add jq curl
