#!/bin/bash
set -e

echo "Starting phirepass daemon addon..."

# Export all options from the JSON file as environment variables
if [ -f /data/options.json ]; then
    eval "$(jq -r 'to_entries | .[] | "export \(.key)=\(.value | @json)"' /data/options.json)"
fi

env

echo "Running daemon..."

exec /app/daemon start
