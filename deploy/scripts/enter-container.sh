#!/bin/bash
# Simple script to enter a running container by name
JDOCK=`docker ps -aqf "name=${1}"`
docker exec -it ${JDOCK} bash
