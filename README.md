# Infra

This repository contains AWS CloudFormation template which deploys a VPC with public and private subnets, a work node in private subnet with admin access via [SSM](https://aws.amazon.com/blogs/infrastructure-and-automation/toward-a-bastion-less-world/).

# Pre-requisites

This project does not use containerised tools, for the lack of time for the project and assumes the tools are installed on the machine that deploys this project:
- AWS CLI
- GNU Makefile
- cfn-lint

The machine must have access to a AWS account with sufficient permissions to deploy cloudformation stacks with IAM capabilities, ec2 permissions.

# Deploy

This project can be deployed in any region.

Deploy command accepts following parameters:

* `ImageID`

Required: false

Description: Amazon Linux 2 Image AMI ID available in the region where the stack is being deployed. If this parameter is not defined then latest Amazon Linux 2 image will be selected using SSM Parameter Store as described in this [AWS blog post](https://aws.amazon.com/blogs/compute/query-for-the-latest-amazon-linux-ami-ids-using-aws-systems-manager-parameter-store/).

Minimal command to deploy the project:
```bash
make deploy
```
:warning: note currently VPC and subnets CIDRs are hardcoded as default values in the CloudFormation template and potentially can clash with other VPCs.

# Connect

Obtain instanceId. At the end of a successful stack deployment InstanceId is printed on the screen. It can also be retrieved at any time by running:
```bash
make get-info
```

## From terminal

```bash
aws ssm start-session --target <instance-id>
```
[Session Manager plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html#install-plugin-macos) may be needed to run this command.

## From console

Navigate to `AWS Systems Manager` -> `Session Manager` -> `Start Session` and paste in InstanceId.

# Cleanup

```bash
make cleanup-all
```
