# syntax = docker/dockerfile:1.4
########################################

FROM alpine:3.18 AS openresty

RUN apk add --no-cache --virtual .build-deps \
    build-base \
    coreutils \
    curl \
    linux-headers \
    make \
    perl-dev \
    readline-dev \
    openssl-dev \
    pcre-dev \
    libxslt-dev \
    zlib-dev \
    libmaxminddb-dev \
    nginx \
    libcap

WORKDIR /usr/src

ARG APPVERSION
ENV APPVERSION=${APPVERSION}
RUN curl -fsSLO https://openresty.org/download/openresty-${APPVERSION}.tar.gz && \
    tar xzf openresty-${APPVERSION}.tar.gz && \
    curl -fsSL https://github.com/leev/ngx_http_geoip2_module/archive/3.3.tar.gz > ngx_http_geoip2_module.tar.gz && \
    tar xzf ngx_http_geoip2_module.tar.gz
RUN cd openresty-${APPVERSION} && ./configure -j2 --with-http_realip_module --with-pcre-jit --with-ipv6 --with-file-aio \
        --with-md5-asm --with-sha1-asm --with-threads \
        --add-dynamic-module=/usr/src/ngx_http_geoip2_module-3.3 \
        --sbin-path=/usr/local/sbin/nginx \
        --conf-path=/etc/nginx/nginx.conf --pid-path=/run/nginx/nginx.pid --lock-path=/run/nginx/nginx.lock \
        --http-client-body-temp-path=/tmp/client_body \
        --http-proxy-temp-path=/tmp/proxy \
        --http-fastcgi-temp-path=/tmp/fastcgi \
        --http-uwsgi-temp-path=/tmp/uwsgi \
        --http-scgi-temp-path=/tmp/scgi \
        --http-log-path=/tmp/access.log \
        --error-log-path=/tmp/error.log \
        --user=nginx --group=nginx && \
    make -j2 && make install

RUN setcap    cap_net_bind_service=+ep /usr/local/sbin/nginx && \
    setcap -v cap_net_bind_service=+ep /usr/local/sbin/nginx

RUN rm -rf /usr/local/openresty/nginx/html/*

###

FROM alpine:3.18 AS nginx-openresty

COPY --from=minio/mc:RELEASE.2022-07-06T14-54-36Z /usr/bin/mc /usr/bin/mc
RUN apk add --no-cache --update libgcc pcre libmaxminddb curl && \
    addgroup -g 101 -S nginx && adduser --disabled-password -S --home /var/lib/nginx --u 100 --gecos "nginx" nginx && \
    install -o nginx -g nginx -d /run/nginx /var/cache/nginx /var/log/nginx /var/lib/nginx/tmp

COPY --from=openresty /usr/local/openresty/luajit   /usr/local/openresty/luajit
COPY --from=openresty /usr/local/openresty/lualib   /usr/local/openresty/lualib
COPY --from=openresty /usr/local/openresty/nginx    /usr/local/openresty/nginx
COPY --from=openresty /usr/lib/nginx                /usr/lib/nginx
COPY --from=openresty /usr/local/sbin               /usr/local/sbin
COPY --from=openresty /etc/nginx                    /etc/nginx
COPY                  nginx.conf                    /etc/nginx/nginx.conf

RUN rm -rf /etc/nginx/conf.d && rm -rf /etc/nginx/sites-enabled && rm -rf /etc/nginx/*.default

###

FROM scratch AS pkg
LABEL org.opencontainers.image.description="Nginx with lua" \
      org.opencontainers.image.licenses="MIT"

COPY --from=nginx-openresty / /
