#!/bin/bash

set -e

echo "Inside the start script ..."

DIR=/docker/app
echo "Changing into directory : $DIR"
cd $DIR
echo "Starting the container ..."
docker-compose up -d db

echo 'start script completed!'
