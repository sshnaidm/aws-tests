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
