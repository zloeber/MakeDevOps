#!/bin/sh

git clone https://github.com/saturnism/gcp-live-k8s-visualizer.git
cd gcp-live-k8s-visualizer
kubectl proxy --www=.
