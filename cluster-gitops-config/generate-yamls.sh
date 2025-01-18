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
