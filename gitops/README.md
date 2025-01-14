# Create a GitOps configuation

For more details see <https://github.com/openshift-kni/cnf-features-deploy/blob/master/ztp/gitops-subscriptions/argocd/README.md>

- Apply manifests to create a namespace:
`oc apply -f manifests/namespace.yaml`

- Pull a ZTP GitOps container Telco uses for GitOps workflows:
`podman pull quay.io/openshift-kni/ztp-site-generator:latest`

- Create a directory and extract there container contents:

```bash
mkdir -p ztp/out
cd ztp
podman run --rm --log-driver=none ztp-site-generator:latest extract /home/ztp --tar | tar x -C ./out
```

- Install GitOps operator from the container:
`oc apply -f ./out/argocd/deployment/openshift-gitops-operator.yaml`

- And get a route of URL for ArgoCD:
`oc get route -n openshift-gitops openshift-gitops-server -ojson | jq -r '.spec.host'`

  You can open this URL and authenticate via Openshift.

- Patch the Operator:
`oc patch argocd openshift-gitops -n openshift-gitops --type=merge --patch-file ./out/argocd/deployment/argocd-openshift-gitops-patch.json`

## GitOps configuration

- Patch application file `./out/argocd/deployment/clusters-app.yaml`. Replace there `path`, `repoURL` and `targetRevision` if need. We will put all configs to `siteconfig` directory:

```bash
sed -i "s@path: .*@path: siteconfig@" ./out/argocd/deployment/clusters-app.yaml
REPO_URL="https://$(oc get route -n gitea -o json | jq -r '.items[0].spec.host')/root/gitops"
sed -i "s@repoURL: .*@repoURL: $REPO_URL@" ./out/argocd/deployment/clusters-app.yaml
```

Do same thing with `policies-app.yaml` file if need:

```bash
sed -i "s@path: .*@path: policy@" ./out/argocd/deployment/policies-app.yaml
REPO_URL="https://$(oc get route -n gitea -o json | jq -r '.items[0].spec.host')/root/gitops"
sed -i "s@repoURL: .*@repoURL: $REPO_URL@" ./out/argocd/deployment/policies-app.yaml
```

Disable autosync if need:

```bash
sed -i "s/\(^.*\)automated:/#\1automated:/" ./out/argocd/deployment/clusters-app.yaml
sed -i "s/\(^.*\)prune: /#\1prune: /" ./out/argocd/deployment/clusters-app.yaml
sed -i "s/\(^.*\)selfHeal: /#\1selfHeal: /" ./out/argocd/deployment/clusters-app.yaml
```

Install the Application:

`oc apply -k ./out/argocd/deployment`

And finally prepare repo connection secret and apply:

```bash
export GIT_URL="https://$(oc get route -n gitea -o json | jq -r '.items[0].spec.host')/root/gitops"
export GIT_REPO_URL="$(echo -n $GIT_URL | base64 -w 0)"
cat manifests/repo_connect.yaml | envsubst > ztp/out/repo_connect.yaml
oc apply -f ztp/out/repo_connect.yaml
```

If you disabled autosync before, that's a time to sync:

```bash
oc patch applications.argoproj.io clusters -n openshift-gitops -p '{"operation": {"sync": { "revision": "HEAD" } }}' --type merge
```
