#!/usr/bin/env bash

#"https://$MASTERIP:$APIPORT/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/"

OS=`uname -s`

if [ $OS != "Darwin" ]; then
  echo "This script is OSX-only. Please do not run it on any other Unix."
  exit 1
fi

if [[ $EUID -eq 0 ]]; then
  echo "This script must NOT be run with sudo/root. Please re-run without sudo." 1>&2
  exit 1
fi

# Current user and group for later
U=`id -u`
G=`id -g`

echo "== Adding environment variables from env_vars.sh =="
. ./env_vars.sh

echo "== Setting kubectl context =="
$CMD_KUBECTL config use-context $CFG_KUBECTL_CONTEXT

helm --kube-context $CFG_KUBECTL_CONTEXT install --name kubernetes-dashboard stable/kubernetes-dashboard

