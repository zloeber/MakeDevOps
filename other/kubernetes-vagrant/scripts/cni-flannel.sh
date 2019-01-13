#!/bin/bash
echo "Configuring CNI plug-in: Flannel"
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
