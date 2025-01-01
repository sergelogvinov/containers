# syntax = docker/dockerfile:1.11
########################################

FROM alpine:3.21 AS openresty-build

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
    libcap \
    brotli \
    brotli-libs \
    brotli-dev \
    git

WORKDIR /usr/src

ARG APPVERSION
ENV APPVERSION=${APPVERSION}
RUN curl -fsSLO https://openresty.org/download/openresty-${APPVERSION}.tar.gz && \
    tar xzf openresty-${APPVERSION}.tar.gz && \
    curl -fsSL https://github.com/leev/ngx_http_geoip2_module/archive/3.4.tar.gz > ngx_http_geoip2_module.tar.gz && \
    tar xzf ngx_http_geoip2_module.tar.gz && \
    git clone --single-branch --depth 2 --recursive https://github.com/google/ngx_brotli.git

###

FROM openresty-build AS openresty

RUN cd openresty-${APPVERSION} && ./configure -j2 --with-http_realip_module --with-pcre-jit --with-ipv6 --with-file-aio \
        --with-md5-asm --with-sha1-asm --with-threads \
        --add-dynamic-module=/usr/src/ngx_http_geoip2_module-3.4 \
        --add-module=/usr/src/ngx_brotli \
        --sbin-path=/usr/local/sbin/nginx \
        --conf-path=/etc/nginx/nginx.conf --pid-path=/run/nginx.pid --lock-path=/run/nginx.lock \
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

FROM openresty-build AS openresty-device-detection

RUN git clone --single-branch --depth 2 --branch master https://github.com/51Degrees/Device-Detection.git device-detection && \
    cd device-detection/nginx && make build trie

RUN cd openresty-${APPVERSION} && ./configure -j2 --with-http_realip_module --with-pcre-jit --with-ipv6 --with-file-aio \
        --with-md5-asm --with-sha1-asm --with-threads \
        --add-dynamic-module=/usr/src/ngx_http_geoip2_module-3.4 \
        --add-module=/usr/src/ngx_brotli \
        --add-dynamic-module=/usr/src/device-detection/nginx/51Degrees_module \
        --with-cc-opt="-DFIFTYONEDEGREES_TRIE -DFIFTYONEDEGREES_NO_THREADING -fcommon" \
        --sbin-path=/usr/local/sbin/nginx \
        --conf-path=/etc/nginx/nginx.conf --pid-path=/run/nginx.pid --lock-path=/run/nginx.lock \
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

FROM alpine:3.21 AS nginx-openresty

RUN apk add --no-cache --update libgcc pcre libmaxminddb curl && \
    addgroup -g 101 -S nginx && adduser --disabled-password -S --home /var/lib/nginx --u 100 --gecos "nginx" nginx && \
    install -o nginx -g nginx -d /run /var/cache/nginx /var/log/nginx /var/lib/nginx/tmp

COPY --from=openresty /usr/local/openresty/luajit   /usr/local/openresty/luajit
COPY --from=openresty /usr/local/openresty/lualib   /usr/local/openresty/lualib
COPY --from=openresty /usr/local/openresty/nginx    /usr/local/openresty/nginx
COPY --from=openresty /usr/lib/nginx                /usr/lib/nginx
COPY --from=openresty /usr/local/sbin               /usr/local/sbin
COPY --from=openresty /etc/nginx                    /etc/nginx
COPY nginx.conf /etc/nginx/nginx.conf

RUN rm -rf /etc/nginx/conf.d && rm -rf /etc/nginx/sites-enabled && rm -rf /etc/nginx/*.default
RUN nginx -t && rm -rf /tmp/* /run/*

###

FROM scratch AS pkg
LABEL org.opencontainers.image.description="Nginx with lua" \
      org.opencontainers.image.licenses="MIT"

COPY --from=nginx-openresty / /
COPY --from=minio/mc:RELEASE.2023-10-30T18-43-32Z /usr/bin/mc /usr/bin/mc

STOPSIGNAL SIGQUIT
CMD ["/usr/local/sbin/nginx", "-g", "daemon off;"]

###

FROM alpine:3.21 AS nginx-openresty-device-detection

RUN apk add --no-cache --update libgcc pcre libmaxminddb curl && \
    addgroup -g 101 -S nginx && adduser --disabled-password -S --home /var/lib/nginx --u 100 --gecos "nginx" nginx && \
    install -o nginx -g nginx -d /run /var/cache/nginx /var/log/nginx /var/lib/nginx/tmp

COPY --from=openresty-device-detection /usr/local/openresty/luajit   /usr/local/openresty/luajit
COPY --from=openresty-device-detection /usr/local/openresty/lualib   /usr/local/openresty/lualib
COPY --from=openresty-device-detection /usr/local/openresty/nginx    /usr/local/openresty/nginx
COPY --from=openresty-device-detection /usr/lib/nginx                /usr/lib/nginx
COPY --from=openresty-device-detection /usr/local/sbin               /usr/local/sbin
COPY --from=openresty-device-detection /etc/nginx                    /etc/nginx
COPY nginx.conf /etc/nginx/nginx.conf

RUN rm -rf /etc/nginx/conf.d && rm -rf /etc/nginx/sites-enabled && rm -rf /etc/nginx/*.default
RUN nginx -t && rm -rf /tmp/* /run/*

###

FROM scratch AS device-detection
LABEL org.opencontainers.image.description="Nginx with lua and device-detection" \
      org.opencontainers.image.licenses="MPL-2.0"

COPY --from=nginx-openresty-device-detection / /
COPY --from=minio/mc:RELEASE.2023-10-30T18-43-32Z /usr/bin/mc /usr/bin/mc

STOPSIGNAL SIGQUIT
CMD ["/usr/local/sbin/nginx", "-g", "daemon off;"]
