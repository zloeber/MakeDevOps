#!/bin/bash
echo "Configuring CNI plug-in: Calico"
sudo kubectl apply -f https://docs.projectcalico.org/v2.1/getting-started/kubernetes/installation/hosted/kubeadm/1.6/calico.yaml