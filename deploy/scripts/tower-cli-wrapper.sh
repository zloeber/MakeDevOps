#!/usr/bin/env bash

# The following will be the binary path of tower that this script will use.

# Computations - UAT
TOWER_CLI_PATH=/home/fndsstb/.local/share/virtualenvs/towercli-updated-s9cPrypW/bin/

# Ingestion - UAT
#TOWER_CLI_PATH="/home/ingstbusr/.local/share/virtualenvs/towercli-updated-kbj4cs3W/bin/"

# Note: Tibco t_dir should be set to the location of this script which should be renamed to tower-cli (no .sh)

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
if [[ -z "${TOWER_VERIFY_SSL}" ]]; then
    TOWER_VERIFY_SSL=False
fi

if [[ -z "${TOWER_USE_TOKEN}" ]]; then
    TOWER_USE_TOKEN=True
fi

#if [[ -z "${TOWER_FORMAT}" ]]; then
#    TOWER_FORMAT="json"
#fi
#if [[ -z "${TOWER_HOST}" ]]; then
#    TOWER_HOST="sharedinfrastructure-tower-dev-us-east-1.aws-shr.nielsencsp.net"
#fi
#if [[ -z "${TOWER_USERNAME}" ]]; then
#    TOWER_USERNAME="changeme"
#fi
#if [[ -z "${TOWER_PASSWORD}" ]]; then
#    TOWER_PASSWORD="changeme"
#fi
#if [[ -z "${TOWER_VERBOSE}" ]]; then
#    TOWER_VERBOSE=False
#fi

${TOWER_CLI_PATH}tower-cli
TOWERCLI_CMD="${TOWER_CLI_PATH}tower-cli $@"

echo "Running ${TOWERCLI_CMD}" 

$TOWERCLI_CMD