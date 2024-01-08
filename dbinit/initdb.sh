#!/bin/bash
export PGUSER=${POSTGRES_USER}

SYSMEM=$(cat /proc/meminfo | grep -i 'memtotal' | grep -o '[[:digit:]]*')
SHARED_BUFFERS=$(( $SYSMEM/4 ))
EFFECTIVE_CACHE_SIZE=$(( $SYSMEM*3/4 ))
MAINTENANCE_WORK_MEM=$(( $SYSMEM/8 ))
WORK_MEM=$(( $SHARED_BUFFERS/50 ))

psql -X -v ON_ERROR_STOP=1 <<EOSQL
ALTER SYSTEM SET search_path TO pgstac, public;
ALTER SYSTEM SET client_min_messages TO WARNING;
ALTER SYSTEM SET shared_buffers='${SHARED_BUFFERS}kB';
ALTER SYSTEM SET effective_cache_size='${EFFECTIVE_CACHE_SIZE}kB';
ALTER SYSTEM SET maintenance_work_mem='${MAINTENANCE_WORK_MEM}kB';
ALTER SYSTEM SET work_mem='${WORK_MEM}kB';
ALTER SYSTEM SET effective_io_concurrency=200;
ALTER SYSTEM SET random_page_cost=1.1;
EOSQL

docker_temp_server_stop
docker_temp_server_start

psql -X -v ON_ERROR_STOP=1 <<EOSQL
CREATE UNLOGGED TABLE sample1 (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text,
    geom geometry(Polygon, 4326)
);
INSERT INTO sample1 (name, geom)
SELECT
    CONCAT('row_', (row_number() over ())::text) as name,
    geom
FROM ST_SquareGrid(1, ST_MakeEnvelope(-180, -85, 180, 85, 4326));

CREATE INDEX ON sample1 USING GIST(geom);
EOSQL
