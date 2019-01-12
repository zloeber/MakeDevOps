#!/bin/bash
kubectl logs -f $(kubectl get pods --namespace default -l "run=cleanup-operator" -o jsonpath="{.items[0].metadata.name}")

# Use simple job to test it
#kubectl create -f https://raw.githubusercontent.com/kubernetes/kubernetes.github.io/master/docs/concepts/workloads/controllers/job.yaml
