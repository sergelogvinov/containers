# syntax = docker/dockerfile:1.4
########################################

FROM alpine:3.9 AS pkg
LABEL org.opencontainers.image.description="Tabix.io UI"
LABEL org.opencontainers.image.licenses=MIT

RUN apk add --no-cache --update nginx && \
    mkdir -p /run/nginx /var/tmp/nginx/client_body && rm -rf /var/lib/nginx/html/* && \
    rm -rf /etc/nginx/conf.d && rm -rf /etc/nginx/sites-enabled

ENV TABIX_RELEASE=18.07.2

WORKDIR /www
RUN wget https://github.com/tabixio/tabix/archive/${TABIX_RELEASE}.tar.gz -O /tmp/tabix.tar.gz && \
    cd /tmp && tar -xf tabix.tar.gz && \
    mv /tmp/tabix-${TABIX_RELEASE}/build/* /www && \
    rm -rf /tmp/*

COPY ["nginx.conf","/etc/nginx/"]

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
