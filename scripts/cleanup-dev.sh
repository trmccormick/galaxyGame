#!/bin/bash

# Stop and remove all containers
docker ps -aq | xargs -r docker stop
docker ps -aq | xargs -r docker rm

# Remove all unused volumes
docker volume prune --all --force

# Remove development log
rm -rf ./data/logs/development.log
