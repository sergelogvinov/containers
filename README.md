# Containers

Our images come in two flavors to support different architectures: `arm64` and `amd64`.
Uses by [helm](https://github.com/sergelogvinov/helm-charts) deployments.

* [Contolplane lb](contolplane-lb) - haproxy load balancer
    * `docker pull ghcr.io/sergelogvinov/openvpn:2.6.11`
    * `docker pull sergelog/openvpn:2.6.11`
* [Fluentd](fluentd) - with common plugins
    * `docker pull ghcr.io/sergelogvinov/fluentd:latest`
    * `docker pull sergelog/fluentd:1.15.3`
* [Keydb](keydb) - keydb with wal-g
    * `docker pull ghcr.io/sergelogvinov/keydb:latest`
* [Mongodb](mongodb) - mongodb with wal-g
    * `docker pull ghcr.io/sergelogvinov/mongodb:latest`
* [Mongosqld](mongosqld) - mongosqld
    * `docker pull ghcr.io/sergelogvinov/mongosqld:latest`
* [Nginx-openrestry](nginx-openrestry) - nginx with lua
    * `docker pull ghcr.io/sergelogvinov/nginx-openrestry:latest`
* [Openvpn](openvpn) - openvpn with google authenticator (otp)
    * `docker pull ghcr.io/sergelogvinov/openvpn:latest`
    * `docker pull sergelog/openvpn:2.5.8-2`
* [PGBouncer](pgbouncer) - postgresql pooler
    * `docker pull ghcr.io/sergelogvinov/pgbouncer:latest`
* [Postgresql](postgresql) - postgresql with wal-g
    * `docker pull ghcr.io/sergelogvinov/postgresql:latest`
* [Tabix](tabix) - postgresql with wal-g
    * `docker pull ghcr.io/sergelogvinov/tabix:latest`

## CICD

* [Github actions runner](github-actions-runner)
    * `docker pull ghcr.io/sergelogvinov/github-actions-runner`
* [Teamcity](teamcity)
    * `docker pull ghcr.io/sergelogvinov/teamcity`

## Utils

* [reviewdog](reviewdog) - is an automated code review tool integrated with any code analysis tools regardless of programming language.
    * `docker pull ghcr.io/sergelogvinov/reviewdog:0.14.2`
* [skopeo](skopeo) - is a command line utility that performs various operations on container images and image repositories.
    * `docker pull ghcr.io/sergelogvinov/skopeo:1.12.0`
* [sops](sops) - is an editor of encrypted files that supports YAML, JSON and BINARY formats and encrypts with AWS KMS and PGP.
    * `docker pull ghcr.io/sergelogvinov/sops:3.7.3`
* [vals](vals) - is a tool for managing configuration values and secrets.
    * `docker pull ghcr.io/sergelogvinov/vals:0.25.0`
* [supercronic](supercronic) - is a tool run jibs with metrics.
    * `docker pull ghcr.io/sergelogvinov/supercronic:0.2.25`
* [wal-g](wal-g) - database backup tool.
    * `docker pull ghcr.io/sergelogvinov/wal-g:2.0.1`
