# Configure routing

Run terraform commands to set up a VPN bastion:

```bash
terraform init
terraform apply
```

Copy `server.conf` to the AWS bastion, it will be a VPN server.
Create (or copy) `static.key` file both to server and client.
Run the VPN server by:

`sudo openvpn --config ./server.conf`

On the client copy same `static.key`, `client.conf` file and run:

`sudo openvpn --config ./client.conf`
