#!/usr/bin/env bash

#Available environment variables:
#TOWER_COLOR
#TOWER_FORMAT
#TOWER_HOST
#TOWER_PASSWORD
#TOWER_USERNAME
#TOWER_VERIFY_SSL
#TOWER_VERBOSE
##TOWER_DESCRIPTION_ON
#TOWER_CERTIFICATE
#TOWER_USE_TOKEN

# Ensure that secrets don't echo and get logged somewhere
#set +x

# Modify the following to suit your needs.
if [[ -z "${TOWER_FORMAT}" ]]; then
    TOWER_FORMAT="human"
fi
if [[ -z "${TOWER_HOST}" ]]; then
    TOWER_HOST="sharedinfrastructure-tower-dev-us-east-1.aws-shr.nielsencsp.net"
fi
if [[ -z "${TOWER_USERNAME}" ]]; then
    TOWER_USERNAME="changeme"
fi
if [[ -z "${TOWER_PASSWORD}" ]]; then
    TOWER_PASSWORD="changeme"
fi
if [[ -z "${TOWER_VERIFY_SSL}" ]]; then
    TOWER_VERIFY_SSL=False
fi
if [[ -z "${TOWER_VERBOSE}" ]]; then
    TOWER_VERBOSE=False
fi
if [[ -z "${TOWER_USE_TOKEN}" ]]; then
    TOWER_USE_TOKEN=True
fi

# tower-cli 
if [[ -z "${1}" ]]; then
    TOWERCLI_CMD='--version'
else
    TOWERCLI_CMD=$1
fi

echo "Running tower-cli ${TOWERCLI_CMD}" 

tower-cli $TOWERCLI_CMD
