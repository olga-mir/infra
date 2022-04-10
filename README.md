# Infra

This repository contains AWS CloudFormation template which deploys a VPC with public and private subnet, a webserver in private subnet and a bastion host for webserver admin access.

# Pre-requisites

This project does not use containerised tools, for the lack of time for the project and assumes the (very basic) tools are installed on the machine that deploys this project:
- AWS CLI
- GNU Makefile

The machine must have access to a AWS account with sufficient permissions to deploy cloudformation stacks with IAM capabilities, ec2 permissions. The credentials are configured in AWS_ environment variables.

# Deploy

This project can be deployed in any region.

Deploy command accepts following parameters:

* `KeyName`

Required: true

Description: The name of the key pair to install on the bastion and the webserver hosts to allow SSH connections.

* `ImageID`

Required: false

Description: Amazon Linux 2 Image AMI ID available in the region where the stack is being deployed. If this parameter is not defined then latest Amazon Linux 2 image will be selected using SSM Parameter Store as described in this [AWS blog post](https://aws.amazon.com/blogs/compute/query-for-the-latest-amazon-linux-ami-ids-using-aws-systems-manager-parameter-store/).

* `AdminCIDR`

Required: false

Description: IP range in CIDR notation to alowlist SSH connection from. If not provided then the IP of the machine used to deploy will be used (with /32 netmask).

## Examples

Minimal command to deploy the project:
```bash
make deploy KeyName=mykey
```

Provide Admin CIDR and AMI:

```bash
make deploy KeyName=mykey AdminCIDR=1.2.3.4/30 ImageID=ami-012feb91d25f5d1b3
```

:warning: note currently VPC and subnets CIDRs are hardcoded as default values in the CloudFormation template and potentially can clash with other VPCs.

# SSH

Add following config to the ssh config file (usually at `~/.ssh/config`)
```
Host bastion
   StrictHostKeyChecking no
   IdentityFile /path/to/my/key
   HostName <bastion-public-ip>
   User ec2-user

Host webserver
   StrictHostKeyChecking no
   IdentityFile /path/to/my/key
   HostName <webserver-private-ip>
   User ec2-user
   ProxyCommand ssh -q -W %h:%p bastion
```

Relevant IPs are printed out at the end of successful deployment or by running `get-ips` at any time:
```bash
make get-ips
```

connect to webserver using:
```bash
ssh webserver
```

# Test

Once ssh config is updated, connect and test httpd service is returning content:

```bash
ssh webserver
curl localhost
timedatectl
```

# Cleanup
```bash
make cleanup-all
```

# Improvements to consider

* Remove bastion host. Bastion is the quickest and most familiar approach to access instance in a private subnet, but it has a lot of drawbacks and there are better ways to connect to hosts (better yet to avoid connecting altogether whenever possible, but that's out of scope).
* Define minimal IAM role required to deploy and maintain this stack.
* If still using bastion: add utility command to add addtional adminCIDR blocks and install authorized keys to easily onboard other team members.
* Expose webserver via DNS. Avoid hardcoding IPs.
* Parameterise VPC and subnets CIDRs.
* Many people dislike Makefile, Taskfile seems to be the new hotness which probably going to replace Make. (yay to even more yaml!)
