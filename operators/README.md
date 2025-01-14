# Install operators on a hub cluster

## Install ACM

Run to apply all manifests one by one, waiting a few minutes between files so reources will be created:

```bash
oc apply -f acm/acm-1.yaml
sleep 200
oc apply -f acm/acm-2.yaml
sleep 200
oc apply -f acm/acm-3.yaml
```

## Install TALM for GitOps operations

```bash
oc apply -f talm/talm-1.yaml
```
