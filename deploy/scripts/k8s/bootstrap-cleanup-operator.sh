#!/bin/bash
# remember to change namespace in RBAC manifests for monitoring namespaces other than "default"
kubectl create -f https://raw.githubusercontent.com/lwolf/kube-cleanup-operator/master/deploy/rbac.yaml

# create deployment
kubectl create -f https://raw.githubusercontent.com/lwolf/kube-cleanup-operator/master/deploy/deployment.yaml

#kubectl logs -f $(kubectl get pods --namespace default -l "run=cleanup-operator" -o jsonpath="{.items[0].metadata.name}")
# Use simple job to test it
#kubectl create -f https://raw.githubusercontent.com/kubernetes/kubernetes.github.io/master/docs/concepts/workloads/controllers/job.yaml
