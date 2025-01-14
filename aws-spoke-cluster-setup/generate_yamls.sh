#!/bin/bash
# Generate secrets file for the OpenShift cluster installation
export SSH_PRIVATE_KEY=$(cat private-ssh-key | sed 's/^/    /')
export PUBLIC_SSH_KEY=$(cat public-ssh-key)
export PULL_SECRET=$(cat pull-secret.json)
export AWS_ACCESS_KEY="${AWS_ACCESS_KEY:-'placeholder'}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-'placeholder'}"

export INSTALL_CONFIG=$(cat install-config.yaml | envsubst | base64 -w 0)
export CLUSTER_NAME=sshnaidm-aws-spoke-cluster

cat manifests/secrets.yaml | envsubst > manifests/secret-apply.yaml
cat manifests/deployment.yaml | envsubst > manifests/deploy-apply.yaml

#Do afterwards:

# oc apply -f manifests/secret-apply.yaml
# oc apply -f manifests/deploy-apply.yaml
