#!/bin/sh
# exit immediately if a command exits with a non-zero status
set -e

echo "Running migrations..."
/app/bin/sipadu eval "Sipadu.Release.migrate"

echo "Starting Phoenix server..."
exec /app/bin/sipadu start
