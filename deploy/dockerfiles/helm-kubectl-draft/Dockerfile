FROM ubuntu:16.04

LABEL maintainer Radu Matei <matei.radu94@gmail.com>

# Latest versions for kubectl, helm and draft
ENV KUBE_LATEST_VERSION="v1.8.0"
ENV HELM_LATEST_VERSION="v2.6.2"
ENV DRAFT_LATEST_VERSION="v0.7.0"

RUN apt-get update && apt-get install -y \
    curl

# Download and install kubectl
RUN curl -LO  https://storage.googleapis.com/kubernetes-release/release/${KUBE_LATEST_VERSION}/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin/kubectl

# Download and install helm
RUN curl -LO  https://storage.googleapis.com/kubernetes-helm/helm-${HELM_LATEST_VERSION}-linux-amd64.tar.gz
RUN tar -xvf helm-${HELM_LATEST_VERSION}-linux-amd64.tar.gz
RUN mv linux-amd64/helm /usr/local/bin 

# Download and install draft
RUN curl -LO \  
    https://github.com/Azure/draft/releases/download/${DRAFT_LATEST_VERSION}/draft-${DRAFT_LATEST_VERSION}-linux-amd64.tar.gz
RUN tar -xvf draft-${DRAFT_LATEST_VERSION}-linux-amd64.tar.gz
RUN mv linux-amd64/draft /usr/local/bin 

# Expose port for kubectl proxy
EXPOSE 8080

ENTRYPOINT ["bash"]