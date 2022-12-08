# syntax = docker/dockerfile:1.4
########################################

FROM --platform=$BUILDPLATFORM ubuntu:20.04 as archive

RUN apt-get update && apt-get install --no-install-recommends -y ca-certificates wget
ARG APPVERSION

WORKDIR /src
RUN wget https://info-mongodb-com.s3.amazonaws.com/mongodb-bi/v2/mongodb-bi-linux-arm64-ubuntu2004-v${APPVERSION}.tgz  -O /src/mongodb-bi-linux-arm64.tgz && \
    wget https://info-mongodb-com.s3.amazonaws.com/mongodb-bi/v2/mongodb-bi-linux-x86_64-ubuntu2004-v${APPVERSION}.tgz -O /src/mongodb-bi-linux-amd64.tgz

RUN tar -xzf /src/mongodb-bi-linux-arm64.tgz && mkdir -p /src/arm64/bin && \
    mv mongodb-bi-linux-arm64-ubuntu2004-v${APPVERSION}/bin/*  /src/arm64/bin/ && \
    tar -xzf /src/mongodb-bi-linux-amd64.tgz && mkdir -p /src/amd64/bin && \
    mv mongodb-bi-linux-x86_64-ubuntu2004-v${APPVERSION}/bin/* /src/amd64/bin/

########################################

FROM ubuntu:20.04 AS pkg

RUN apt-get update && apt-get install --install-suggests -y ca-certificates libssl1.1 libkrb5-3

ARG TARGETARCH
COPY --from=archive --chown=0:0 ["/src/${TARGETARCH}/bin","/usr/local/bin"]

### ??
# FROM gcr.io/distroless/base-debian10
# COPY --from=build ["/usr/lib/x86_64-linux-gnu/libkrb5.so*",        "/usr/lib/x86_64-linux-gnu/"]
# COPY --from=build ["/usr/lib/x86_64-linux-gnu/libgssapi_krb5.so*", "/usr/lib/x86_64-linux-gnu/"]
# COPY --from=build ["/usr/lib/x86_64-linux-gnu/libk5crypto.s*",     "/usr/lib/x86_64-linux-gnu/"]
# COPY --from=build ["/usr/local/bin/mongo*","/usr/local/bin/"]

USER 1000
ENTRYPOINT ["/usr/local/bin/mongosqld"]
