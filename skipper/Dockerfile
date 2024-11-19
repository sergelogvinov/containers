# syntax = docker/dockerfile:1.6
########################################
ARG APPVERSION
########################################

FROM --platform=$BUILDPLATFORM golang:1.23.3-bookworm AS builder

RUN apt-get update && apt-get install -y cmake git build-essential

WORKDIR /go-build
RUN git clone --single-branch --depth 2 --branch ja3 https://github.com/sergelogvinov/go.git .

WORKDIR /go-build/src
ENV GOROOT=/go-build
RUN bash make.bash
ENV PATH=/go-build/bin:$PATH

###

ARG APPVERSION
WORKDIR /go/src/skipper
RUN git clone --single-branch --depth 2 --branch ${APPVERSION}-ja3 https://github.com/sergelogvinov/skipper.git .
RUN go mod download

ARG VERSION=${APPVERSION}
ENV CGO_ENABLED=0 GOOS=linux
RUN make clean && \
    GOARCH=amd64 go build -o bin/skipper.amd64 -ldflags "-X main.version=${VERSION} -X main.commit=${COMMIT_HASH}" ./cmd/skipper && \
    GOARCH=arm64 go build -o bin/skipper.arm64 -ldflags "-X main.version=${VERSION} -X main.commit=${COMMIT_HASH}" ./cmd/skipper && \
    ./bin/skipper.`go env GOARCH` -version

#######

FROM --platform=${TARGETARCH} scratch AS pkg
LABEL org.opencontainers.image.description="Zalando skipper" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.source="https://github.com/zalando/skipper"

COPY --from=gcr.io/distroless/static-debian12:nonroot . .
ARG TARGETARCH
COPY --from=builder /go/src/skipper/bin/skipper.${TARGETARCH} /usr/bin/skipper

ENTRYPOINT ["/usr/bin/skipper"]
