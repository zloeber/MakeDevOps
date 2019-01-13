#!/bin/sh

echo "Setting up a Jenkins helm chart"
helm install --name jenkins --set Master.ServiceType=NodePort,Persistence.Enabled=false stable/jenkins