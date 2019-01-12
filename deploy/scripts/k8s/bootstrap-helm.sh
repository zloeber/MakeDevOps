#!/usr/bin/env bash
# Required environment variables
#CONTAINER_DIR=/opt/nfsdata
#export SOURCE_DIR="/Users/${USER}/nfsdata"
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

echo "Creating tiller service account and role binding..."
$CMD_KUBECTL -n kube-system create sa tiller
$CMD_KUBECTL create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount kube-system:tiller

echo "Downloading and installing helm..."
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get -s -S | sudo bash
helm --kube-context $CFG_KUBECTL_CONTEXT init --service-account tiller

echo "Adding incubator helm repo..."
helm --kube-context $CFG_KUBECTL_CONTEXT repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
helm repo update

echo "source <(helm completion bash)" >> $HOME/.bashrc
echo "source <(helm completion bash)" >> $HOME/.profile

echo "Done."