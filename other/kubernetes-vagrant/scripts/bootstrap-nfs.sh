#!/bin/bash
echo "Configuring NFS"
kubectl apply -f nfs-rbac.yaml
kubectl apply -f nfs-deployment.yaml
kubectl apply -f nfs-storageclass.yaml

echo "Making nfs-storage the default storage class"
kubectl patch storageclass nfs-storage -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
