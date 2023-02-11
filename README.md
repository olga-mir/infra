# Infra

This repository contains AWS CloudFormation template which deploys a VPC with public and private subnets, a work node in private subnet with admin access via [SSM](https://aws.amazon.com/blogs/infrastructure-and-automation/toward-a-bastion-less-world/).

# Pre-requisites

This project does not use containerised tools, for the lack of time for the project and assumes the tools are installed on the machine that deploys this project:
- AWS CLI
- GNU Makefile
- cfn-lint

The machine must have access to a AWS account with sufficient permissions to deploy cloudformation stacks with IAM capabilities, ec2 permissions.

# Deploy

```bash
make deploy
```

`ImageID` parameter can be set to use specific AMI. If not set, Amazon Linux 2022 AMI will be selected using SSM query as described in [AWS blog post](https://aws.amazon.com/blogs/compute/query-for-the-latest-amazon-linux-ami-ids-using-aws-systems-manager-parameter-store/).

# Connect

At the end of a successful deployment `InstanceId` is printed on the screen. Also it can be obtained with `get-info` make target and then connect with `ssm` using:

```bash
aws ssm start-session --target <instance-id>
```

The shortcut for the above is `connect`:

```bash
make connect
```

[Session Manager plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html#install-plugin-macos) may be needed to run this command.


# Cleanup

```bash
make cleanup
```

# Amazon Linux 2022

Official documentation [comparison to AL2](https://docs.aws.amazon.com/linux/al2022/ug/compare-al2-to-AL2022.html)

SSM parameter used to find AMI image for this stack is `/aws/service/ami-amazon-linux-latest/al2022-ami-kernel-5.15-x86_64`.
Information on the produced OS can be found in the dump file stored in this repo [here](./journal/71fa4-bpf-intro)

## Install BCC and tools

Currently init script is used to install all the tools. Copy [./scripts/init.sh](./scripts/init.sh) to the VM and run it.

Check BCC tools are installed:

```
sh-5.2$ sudo /usr/share/bcc/tools/execsnoop
PCOMM            PID    PPID   RET ARGS
sh-5.2$ sudo /usr/share/bcc/tools/biosnoop
TIME(s)     COMM           PID    DISK    T SECTOR     BYTES  LAT(ms)
0.000000    kworker/u4:4   2222   nvme0n1 W 989072     4096      0.61
0.079939    kworker/u4:4   2222   nvme0n1 W 9206104    4096      0.64
2.720008    kworker/u4:4   2222   nvme0n1 W 9537952    4096      0.71
```
