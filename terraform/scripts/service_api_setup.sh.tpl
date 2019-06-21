#!/bin/bash

sleep 5

cd /etc/service
docker build -f Dockerfile-api -t service_api .
docker run --name service_api -d -p 5000:5000 -e DB_HOST=${DB_IP} -e RABBIT_HOST=${BROKER_IP} service_api
