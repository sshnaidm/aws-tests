#!/bin/bash

export CLUSTER_NAME="sshnaidm-aws-case"
export PUBLIC_SSH_KEY=$(cat public-ssh-key)
export PULL_SECRET=$(cat pull-secret.json)
export BASE_DOMAIN="telco5g-ci.devcluster.openshift.com"
export AWS_ZONE="us-east-1a"
export AWS_REGION="us-east-1"

cat install-config-example.yaml | envsubst > install-config.yaml
mkdir -p installdir
cp install-config.yaml installdir/install-config.yaml

AWS_PROFILE=telco-ci ./openshift-install create cluster --dir installdir/ --log-level debug
