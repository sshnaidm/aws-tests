#!/bin/bash

export IMAGE="img4.16.9-multi-appsub"
export PUBLIC_SSH_KEY=$(cat public-ssh-key)
export PULL_SECRET=$(cat pull-secret.json | base64 -w 0)
export USER_NAME=$(echo root | base64 -w 0)
export USER_PASSWORD=$(echo calvin | base64 -w 0)
export LOCAl_DOMAIN="my.local.domain.lab"
export CLUSTER_NAME="cluster1"
export APP_NAME="clusters"
export VPN_INTERNAL_HOST_IP="22.22.22.22"
export CLUSTER_INTERNAL_HOST_IP="11.11.11.11"
export CLUSTER_INTERNAL_GW_IP="33.33.33.33"
export CLUSTER_INTERNAL_CIDR="111.111.111.0/24"
export CLUSTER_INTERNAL_MAC="00:00:00:00:00:00"


mkdir -p repo/policy repo/siteconfig
cat templates/secret.yaml | envsubst > repo/siteconfig/secret.yaml
cat templates/site-config.yaml | envsubst > repo/siteconfig/site-config.yaml
cp templates/kustomization.yaml repo/siteconfig/kustomization.yaml
cp templates/kustomization_policy.yaml repo/policy/kustomization.yaml
cp templates/ns.yaml repo/policy/ns.yaml

## Create manifests for AWS spoke cluster

export AWS_ACCESS_KEY="${AWS_ACCESS_KEY:-'placeholder'}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-'placeholder'}"
export SSH_PRIVATE_KEY=$(cat private-ssh-key | sed 's/^/    /')
export PUBLIC_SSH_KEY=$(cat public-ssh-key)
export PULL_SECRET=$(cat pull-secret.json)
export AWS_SPOKE_CLUSTER_NAME="my-aws-cluster"
export INSTALL_CONFIG=$(cat install-config.yaml | envsubst | base64 -w 0)

cat templates/aws-secrets.yaml | envsubst > repo/aws/secret-apply.yaml
cat templates/aws-deploy.yaml | envsubst > repo/aws/deploy-apply.yaml

## Create ArgoCD project and application.
oc apply -f templates/argocd-project.yaml
cat templates/argocd-application.yaml | envsubst > application.yaml
REPO_URL="https://$(oc get route -n gitea -o json | jq -r '.items[0].spec.host')/root/gitops"
sed -i "s@repoURL: .*@repoURL: $REPO_URL@" application.yaml
