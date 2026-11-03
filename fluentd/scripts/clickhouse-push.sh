#!/bin/sh

CLICKHOUSE_HOST=${CLICKHOUSE_HOST:-clickhouse.logs.svc}
CLICKHOUSE_USER=${CLICKHOUSE_USER:-writer}
CLICKHOUSE_PASS=${CLICKHOUSE_PASS:-FAKE}
CLICKHOUSE_TABLE=$1

for slot in 1 2; do
  exec 9> "/tmp/fluentd-clickhouse-insert-${slot}.lock" || exit 1
  flock --nonblock 9
  lock_status=$?
  case "$lock_status" in
    0) break ;;
    1) ;;
    *) exit "$lock_status" ;;
  esac
done

if [ "$lock_status" -ne 0 ]; then
  echo "Both ClickHouse INSERT slots are busy; retry this chunk later" >&2
  exit 75
fi

exec /usr/bin/clickhouse-client --host="${CLICKHOUSE_HOST}" --user="${CLICKHOUSE_USER}" --password="${CLICKHOUSE_PASS}" --compression true --query="INSERT INTO ${CLICKHOUSE_TABLE} FORMAT JSONEachRow" < "$2"
