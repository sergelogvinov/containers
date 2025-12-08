# syntax = docker/dockerfile:1.16
########################################
ARG APPVERSION=8.11.1
########################################

FROM alpine:3.23 AS pkg
LABEL org.opencontainers.image.description="Curl with utils" \
      org.opencontainers.image.licenses="MIT"

RUN apk add jq curl
