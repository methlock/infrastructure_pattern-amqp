#!/bin/bash

sleep 5

mkdir /etc/mysql
touch /etc/mysql/docker-compose.yml

cat > /etc/mysql/docker-compose.yml << EOF
version: '3.3'
services:
  db:
    image: mysql:5.7
    restart: always
    environment:
      MYSQL_DATABASE: 'db'
      MYSQL_USER: 'user'
      MYSQL_PASSWORD: 'password'
      MYSQL_ROOT_PASSWORD: 'password'
    ports:
      - '3306:3306'
    expose:
      - '3306'
    volumes:
      - my-db:/var/lib/mysql
volumes:
  my-db:
EOF

# running
docker-compose -f /etc/mysql/docker-compose.yml up -d