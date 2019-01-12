#!/bin/bash

# variables defined in .env will be exported into this script's environment:
set -a
source .env

# Let's delete all containers that have a `my-project_` prefix:
# (by deleting/re-deploying our containers, this script is now idempotent!):
docker rm -f `docker ps -aq -f name=my-project_*`


# To avoid substituting nginx variables, which also use the shell syntax,
# we'll specify only the variables that will be used in our nginx config:
NGINX_VARS='$DOMAINS:$APP_CONTAINER_NAME'

# Now lets populate our nginx config templates to get an actual nginx config
# (which will be loaded into our nginx container):
envsubst "$NGINX_VARS" < nginx.conf > nginx-envsubst.conf

# Let's populate the variables in our compose file template,
# then deploy it!
cat compose.yml | envsubst | docker-compose -f - -p my-project_ up -d