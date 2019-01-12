#!/bin/sh
helm install --name cert-manager -f cert-manager-values.yaml stable/cert-manager
kubectl create -f letsencrypt-clusterissuer-prod.yaml
kubectl create -f letsencrypt-clusterissuer-staging.yaml
