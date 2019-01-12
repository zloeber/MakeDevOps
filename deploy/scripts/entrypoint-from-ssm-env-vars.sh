#!/bin/bash

# To use just set a variable with SSM_<target_env_var>=<ssm_parameter_store_path>
# e.g. SSM_database_password=prod/myservice/database-password

function get_parameter {
    SSM_ENV_VAR_NAME=$1
    ENV_VAR_NAME=`echo "$SSM_ENV_VAR_NAME" | cut -c5-`
    SSM_PARAM_NAME="${!SSM_ENV_VAR_NAME}"

    echo "Getting parameter $SSM_PARAM_NAME from SSM parameter store if it exists and setting into the variable $ENV_VAR_NAME"

    SSM_VALUE=`aws --profile ${AWS_SSM_PS_PROFILE} ssm get-parameters --with-decryption --names "${SSM_PARAM_NAME}"  --query 'Parameters[*].Value' --output text`

    COMMAND="export $ENV_VAR_NAME=$SSM_VALUE"
    eval ${COMMAND}
}

while read name ; do 
    get_parameter $name
done <<EOT
$(printenv | grep -o '^SSM_[^=]*')
EOT

exec "$@"