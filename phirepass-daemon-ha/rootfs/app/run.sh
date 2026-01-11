#!/bin/bash
set -e

echo "Starting phirepass daemon addon..."

PORT=${PORT:-8085}

env

echo "Running on port: $PORT"

ls -lah /app

exec /app/daemon start
