#!/bin/sh

# tower-cli 
if [[ -z "${1}" ]]; then
    JOB_TEMPLATE="1"
else
    JOB_TEMPLATE=$1
fi

if [[ -z "${2}" ]]; then
    JOB_PARAM_FILE="/src/@towercli-${JOB_TEMPLATE}-params.yml"
else
    JOB_PARAM_FILE=$2
fi

if [[ -z EXTRA_PARAMS ]]; then
    EXTRA_PARAMS=""
    # EXTRA_PARAMS="--extra-vars=/src/airflow/@0-airflow-common-params.yml"
fi

# Launch Job and wait until a completion status is determined
tower-cli job launch \
    --monitor \
    --use-token \
    --job-template=$JOB_TEMPLATE \
    --extra-vars=$JOB_PARAM_FILE $EXTRA_PARAMS
