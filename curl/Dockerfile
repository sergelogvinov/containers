# syntax = docker/dockerfile:1.6
########################################
ARG APPVERSION
########################################

FROM alpine:3.19 AS pkg
LABEL org.opencontainers.image.description="Curl with utils" \
      org.opencontainers.image.licenses="MIT"

RUN apk add jq curl
