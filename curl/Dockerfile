# syntax = docker/dockerfile:1.15
########################################
ARG APPVERSION=8.11.1
########################################

FROM alpine:3.21 AS pkg
LABEL org.opencontainers.image.description="Curl with utils" \
      org.opencontainers.image.licenses="MIT"

RUN apk add jq curl
