# Configure

Run script to generate YAMLs: `./generate_yamls.sh`

Commit and push to the repo:

```bash
export MY_GIT_PASS=$(cat git-password)
export GIT_HOST="$(oc get route -n gitea -o json | jq -r '.items[0].spec.host')"

cd repo
git init
git add siteconfig
git add policy # all files
git commit -m "Initial commit with GitOps files"
git remote add origin https://root:${MY_GIT_PASS}@${GIT_HOST}/root/gitops  # root user and root password
git push --set-upstream origin master
```

## Configure Ingress controllers on AWS hub

According to docs <https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.12/html/clusters/cluster_mce_overview#enable-cim-aws>

```bash
ROUTE=$(oc get routes assisted-image-service -n multicluster-engine -ojson | jq -r ".spec.host")
domain=$(echo $ROUTE | sed "s/.*apps\.\(.*\)/\1/g")

cat << EOF | envsubst | oc apply -f -
apiVersion: operator.openshift.io/v1
kind: IngressController
metadata:
  name: ingress-controller-with-nlb
  namespace: openshift-ingress-operator
spec:
  domain: nlb-apps.$domain
  routeSelector:
      matchLabels:
        router-type: nlb
  endpointPublishingStrategy:
    type: LoadBalancerService
    loadBalancer:
      scope: External
      providerParameters:
        type: AWS
        aws:
          type: NLB
EOF
```

Add the following lines to the assisted-image-service route:

```yaml
metadata:
  labels:
    router-type: nlb
  name: assisted-image-service
```

Add internal DNS as a forwarder for internal domain and hostnames:

`oc edit dns.operator/default`

```yaml
spec:
  servers:
  - name: internal-dns
    zones:
    - my.local.domain.lab  # your internal domain
    forwardPlugin:
      upstreams:
      - 192.168.x.x  # your internal dns name accessible by VPN from cluster
```
