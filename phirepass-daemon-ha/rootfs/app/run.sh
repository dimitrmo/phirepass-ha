#!/bin/bash
set -e

echo "Starting phirepass daemon addon..."

# Export all options from the JSON file as environment variables
if [ -f /data/options.json ]; then
    while IFS= read -r key value; do
        export "$key=$value"
    done < <(jq -r 'to_entries | .[] | "\(.key)=\(.value)"' /data/options.json)
fi

env

echo "Running daemon..."

exec /app/daemon start
