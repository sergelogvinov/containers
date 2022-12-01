#!/bin/bash
set -e

REDIS_CONFIG=${REDIS_CONFIG:-/etc/redis.conf}

# allow arguments to be passed to redis-server
if [[ ${1:0:1} = '-' ]]; then
  EXTRA_ARGS="$@"
  set --
fi

echo "Starting redis-server..."
exec /usr/local/bin/redis-server ${REDIS_CONFIG} ${EXTRA_ARGS}
