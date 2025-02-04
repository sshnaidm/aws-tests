# Install the OCP cluster on AWS

## Download the installer

Download your version of installer from: <https://mirror.openshift.com/pub/openshift-v4/clients/ocp/>

Find a `openshift-install-linux.tar.gz` file and unpack it.

## Execute the installation using given install-config.yaml

Run:

```bash
mkdir my_install
cp install-config.yaml my_install/
AWS_PROFILE=telco-ci ./openshift-install create cluster --dir my_install/ --log-level debug
```

In the end it will display `kubeadmin` user password, kubeconfig path and console URL.

## Get Instance ID

Run:

`oc --kubeconfig=kubeconfig get node -o json | jq '.items[0].spec.providerID' | grep -o "i-[a-z0-9]*"`

## Find subnet ID of the Instance

Run:

`aws --profile telco-ci --region us-east-1 ec2 describe-instances --instance-ids i-03f73887f58d31c18 --query "Reservations[].Instances[].NetworkInterfaces[].SubnetId" --output text`

where `telco-ci` is your profile and `us-east-1` is the region you deployed OCP, `i-03f73887f58d31c18` is the instance ID you found in a previous command.

## Find IP of the instance

Run:

`oc --kubeconfig=kubeconfig get node -o json | jq -r '.items[0].status.addresses[] | select(.type == "InternalIP") | .address'`

## Export them for the next steps

```bash
export INSTANCE_IP=...
export SUBNET_ID=...
```
