#!/bin/bash
set -e

echo "Starting phirepass daemon addon..."

cat /data/options.json

# Read port from Home Assistant options
if [ -f /data/options.json ]; then
    PORT=$(jq -r '.port // 8080' /data/options.json)
else
    PORT=${PORT:-8080}
fi

export PORT

echo "Running on port: $PORT"

ls -lah /app

exec /app/daemon start
