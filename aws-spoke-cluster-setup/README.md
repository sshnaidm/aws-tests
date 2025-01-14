# Deploy spoke cluster

## Define a few environment variables and prepare files

1. Define a cluster name: `export CLUSTER_NAME=my-cluster`
2. Prepare a pull secret file for downloading images from quay.io and put it in this folder as `pull-secret.json`, it should one line file.
3. Prepare SSH public and private keys and put in this folder as `private-ssh-key` and `public-ssh-key`. You can generate them with `ssh-keygen ...`
4. Set environment variables for authentication with AWS:
   `export AWS_ACCESS_KEY=<my-key>`
   `export AWS_SECRET_ACCESS_KEY=<my-secret-key>`
5. Run `generate_yamls.sh` script to generate secrets and deployment manifests: `./generate_yamls.sh` .It will create `secret-apply.yaml` and `deploy-apply.yaml` in `manifests` folder.
6. Apply generated manifests, firstly secrets: `oc apply -f manifests/secret-apply.yaml` and then deployment: `oc apply -f manifests/deploy-apply.yaml`
7. Watch cluster creation in console or check with command: `oc get managedcluster`

## Example

```bash
export CLUSTER_NAME=my-cluster
export AWS_ACCESS_KEY=<you key>
export AWS_SECRET_ACCESS_KEY=<your secret key>

./generate_yamls.sh

oc apply -f manifests/secret-apply.yaml
oc apply -f manifests/deploy-apply.yaml

oc get managedcluster
```
