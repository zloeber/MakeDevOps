#!/bin/bash
# $1 = Path

function create_tf_files {
    thispath="${1}"
    mkdir -p "${thispath}"
    touch "${thispath}/var.tf"
    touch "${thispath}/outputs.tf"
    touch "${thispath}/main.tf"
}

function create_tf_service_folder_tree {
    thisenv="${1}/${2}"
    service="${3}"

    create_tf_files "${thisenv}/vpc/"
    mkdir -p "${thisenv}/services"
    create_tf_files "${thisenv}/services/${service}/"
}

function create_tf_service_data_folder_tree {
    thisenv="${1}/${2}"
    provider="${3}"

    mkdir -p "${thisenv}/data-storage"
    create_tf_files "${thisenv}/data-storage/${provider}/"
}

function create_tf_mgmt_folder_tree {
    thispath="${1}"

    create_tf_files "${thispath}/mgmt/vpc/"

    mkdir -p "${thispath}/mgmt/services"
    create_tf_files "${thispath}/mgmt/services/bastion-host/"
    create_tf_files "${thispath}/mgmt/services/jenkins/"
}

function create_tf_global_folder_tree {
    thispath="${1}"

    create_tf_files "${thispath}/global/iam/"
    create_tf_files "${thispath}/global/route53/"
    create_tf_files "${thispath}/global/s3/"
}

PROJECT_PATH=${1:=`pwd`}

echo "Creating Terraform Project Template: ${PROJECT_PATH}"
create_tf_mgmt_folder_tree "${PROJECT_PATH}"
create_tf_global_folder_tree "${PROJECT_PATH}"

create_tf_service_folder_tree "${PROJECT_PATH}" "uat" "frontend-app"
create_tf_service_data_folder_tree "${PROJECT_PATH}" "uat" "mysql"

create_tf_service_folder_tree "${PROJECT_PATH}" "prod" "frontend-app"
create_tf_service_data_folder_tree "${PROJECT_PATH}" "prod" "mysql"
