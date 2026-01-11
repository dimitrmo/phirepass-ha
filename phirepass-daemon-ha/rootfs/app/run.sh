#!/bin/bash
set -e

echo "Starting phirepass daemon addon..."

env

echo "Configured port: $PORT"

PORT=${PORT:-8085}

env

echo "Running on port: $PORT"

ls -lah /app

exec /app/daemon start
