#!/bin/sh

CLICKHOUSE_HOST=${CLICKHOUSE_HOST:-clickhouse.logs.svc}
CLICKHOUSE_USER=${CLICKHOUSE_USER:-writer}
CLICKHOUSE_PASS=${CLICKHOUSE_PASS:-FAKE}
CLICKHOUSE_DB=${CLICKHOUSE_DB:-default}
CLICKHOUSE_TABLE=$1

cat $2 | /usr/bin/clickhouse-client --host=${CLICKHOUSE_HOST} --user="${CLICKHOUSE_USER}" --password=${CLICKHOUSE_PASS} --database="${CLICKHOUSE_DB}" --compression true --query="INSERT INTO ${CLICKHOUSE_TABLE} FORMAT JSONEachRow" && rm -f $2
