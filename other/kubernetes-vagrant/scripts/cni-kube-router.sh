#!/bin/bash
echo "Configuring CNI plug-in: kube-router"
kubectl apply -f https://raw.githubusercontent.com/cloudnativelabs/kube-router/336989088a24c0fd483db0a28a3d0b14129a360e/daemonset/kubeadm-kuberouter.yaml