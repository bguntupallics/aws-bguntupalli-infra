#!/bin/bash

set -e

echo "Inside the start script ..."

DIR=/docker/app
echo "Changing into directory : $DIR"
cd $DIR
aws ecr get-login-password --region us-east-1| docker login --username AWS --password-stdin 009015658576.dkr.ecr.us-east-1.amazonaws.com
docker pull --platform linux/amd64 009015658576.dkr.ecr.us-east-1.amazonaws.com/bguntupalli/myapi:latest
docker tag 009015658576.dkr.ecr.us-east-1.amazonaws.com/bguntupalli/myapi:latest bguntupalli/myapi:latest
echo "Starting the container ..."
#docker-compose up -d db
#sleep 10
docker-compose up -d myapi

echo 'start script completed!'
