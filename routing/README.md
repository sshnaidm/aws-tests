# Set up communication between internal network and AWS VPC

Export the public IP of the bastion (from Terraform output or by command) and find internal IP in cluster subnet:

```bash
export BASTION_INSTANCE_ID="i-0..."
export PUBLIC_BASTION_IP=$(aws --profile telco-ci --region us-east-1 ec2 describe-instances --instance-ids $BASTION_INSTANCE_ID --query 'Reservations[].Instances[].NetworkInterfaces[?Attachment.DeviceIndex==`0`].Association.PublicIp' --output text)
export CLUSTER_SUBNET_BASTION_IP=$(aws --profile telco-ci --region us-east-1 ec2 describe-instances --instance-ids $BASTION_INSTANCE_ID --query 'Reservations[].Instances[].NetworkInterfaces[?Attachment.DeviceIndex==`1`].PrivateIpAddress' --output text)
```

On cluster machine (coreos):

```bash
ip route add 10.8.0.2 via $CLUSTER_SUBNET_BASTION_IP  # IP of interface of AWS bastion in cluster subnet eth1
ip route add 10.6.105.0/24 via $CLUSTER_SUBNET_BASTION_IP  # IP of interface of AWS bastion in cluster subnet eth1
```
