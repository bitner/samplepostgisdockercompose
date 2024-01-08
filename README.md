Make sure to set environment variables
`set -a; source .env; set +a;`

Make sure to kill any running instance along with getting rid of any existing postgres data volume
`docker compose down -v`

Start database in background
`docker compose up -d`

View Postgres Logs
`docker compose logs -f`
