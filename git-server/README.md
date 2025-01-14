# Install git server Gitea based

Create a deployment: `oc create -f gitea-deployment.yaml`

Discover routes: `oc get route -n gitea`

The host part will be used for server URL:

```bash
GIT_HOST=$(oc get route -n gitea -o json | jq -r '.items[0].spec.host')
GIT_URL=https://$GIT_HOST
```

The service has a URL: `$GIT_URL`
For GitOps we'll create a repo `gitops` in `root` user org, so `origin` will be: `$GIT_URL/root/gitops`
Set your desired password in file `git-password`

In your directory with files do:

```bash
export MY_GIT_PASS=$(cat git-password)
git init
git add . # all files
git commit -m "Initial commit with GitOps files"
git remote add origin https://root:${MY_GIT_PASS}@${GIT_URL}/root/gitops  # root user and root password
git push origin master
```

The user has a password `root` by default, change this:

```bash
export MY_GIT_PASS=$(cat git-password)
oc exec -it $(oc get pod -n gitea -oname) -n gitea su git -- bash -c "/usr/local/bin/gitea admin user change-password -u root -p $MY_GIT_PASS"
```

Open `https://$GIT_HOST` and log in with your root password to confirm it.
