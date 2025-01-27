# syntax = docker/dockerfile:1.11
########################################

FROM --platform=$BUILDPLATFORM node:18-alpine3.16 AS build

RUN apk add --no-cache --update git wget

ARG APPVERSION
ENV APPVERSION=${APPVERSION}
WORKDIR /www
RUN wget https://github.com/tabixio/tabix/archive/${APPVERSION}.tar.gz -O /tmp/tabix.tar.gz && \
    cd /tmp && tar -xf tabix.tar.gz && \
    cd tabix-${APPVERSION} && \
    echo 'nodeLinker: node-modules' > .yarnrc.yml && \
    yarn set version 3.1.1 && \
    yarn install && yarn build && \
    mv /tmp/tabix-${APPVERSION}/dist/* /www/

########################################

FROM alpine:3.21 AS pkg
LABEL org.opencontainers.image.description="Tabix.io UI" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.url="https://tabix.io" \
      org.opencontainers.image.source="https://github.com/tabixio/tabix"

RUN apk add --no-cache --update nginx && \
    mkdir -p /run/nginx /var/lib/nginx/tmp/client_body && rm -rf /var/lib/nginx/html/* && \
    rm -rf /etc/nginx/conf.d && rm -rf /etc/nginx/sites-enabled

WORKDIR /www
COPY --from=build ["/www","/www"]
COPY ["nginx.conf","/etc/nginx/"]

USER nginx
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
