#!/bin/bash

sleep 5

mkdir /etc/rabbit
touch /etc/rabbit/docker-compose.yml

cat > /etc/rabbit/docker-compose.yml << EOF
version: "3"
services:
  rabbitmq:
    image: bitnami/rabbitmq:latest
    ports:
      - 15672:15672
      - 5672:5672
EOF

# running
docker-compose -f /etc/rabbit/docker-compose.yml up -d
