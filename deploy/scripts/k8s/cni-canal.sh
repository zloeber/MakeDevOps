#!/bin/bash
echo "Configuring CNI plug-in: Canal"
kubectl --kubeconfig /etc/kubernetes/admin.conf apply -f "https://raw.githubusercontent.com/projectcalico/canal/master/k8s-install/1.7/rbac.yaml"
wget -q "https://raw.githubusercontent.com/projectcalico/canal/master/k8s-install/1.7/canal.yaml" -P /tmp
sed 's/canal_iface: ""/canal_iface: "enp0s8"/' -i /tmp/canal.yaml
kubectl --kubeconfig /etc/kubernetes/admin.conf apply -f /tmp/canal.yaml
