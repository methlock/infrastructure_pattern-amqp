#!/bin/bash

sleep 5

cd /etc/service
docker build -f Dockerfile-worker -t service_worker .
docker run --name service_worker -d -p 5000:5000 -e DB_HOST=${DB_IP} -e RABBIT_HOST=${BROKER_IP} service_worker
