#!/bin/bash
# scripts/overnight_docker_wrapper.sh
# Universal wrapper for running overnight scripts in Docker

set -e

SCRIPT_NAME=$1
shift  # Remove script name from args

if [ -z "$SCRIPT_NAME" ]; then
    echo "Usage: $0 <script_name> [args...]"
    echo "Example: $0 overnight_geotiff_setup.sh"
    exit 1
fi

# Check if we're in Docker (has DOCKER_CONTAINER env var or typical container paths)
if [ -n "$DOCKER_CONTAINER" ] || [ -f "/.dockerenv" ] || grep -q docker /proc/1/cgroup 2>/dev/null; then
    echo "Running in Docker container - executing directly"
    exec "./$SCRIPT_NAME" "$@"
else
    echo "Running on host - executing in Docker container"
    # Copy script to container if needed
    docker cp "$SCRIPT_NAME" web:/home/galaxy_game/ 2>/dev/null || true

    # Execute in container with proper environment
    exec docker exec -i web bash -c "
        cd /home/galaxy_game && \
        export RAILS_ENV=\${RAILS_ENV:-development} && \
        export DATABASE_URL=\${DATABASE_URL:-} && \
        chmod +x '$SCRIPT_NAME' && \
        './$SCRIPT_NAME' $@"
fi