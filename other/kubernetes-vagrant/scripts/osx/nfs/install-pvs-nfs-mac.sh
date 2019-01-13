#!/usr/bin/env bash
# See env_vars.sh for required environment variables!
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

echo "== Configuring NFS rbac for K8s =="
$CMD_KUBECTL apply -f nfs-rbac.yaml

echo "== Deploying NFS for K8s =="
echo "== Local Server: ${NFS_SERVER} =="
echo "== Local Path: ${SOURCE_DIR} =="
$CMD_KUBECTL apply -f nfs-deployment.yaml

echo "== Deploying NFS storageclass for K8s =="
$CMD_KUBECTL apply -f nfs-storageclass.yaml

echo "== Deploying NFS storageclass  as default PV for K8s =="
$CMD_KUBECTL patch storageclass nfs-storage -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

$CMD_KUBECTL patch storageclass hostpath -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'