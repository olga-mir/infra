## AWS general purpose node

`network-setup.yaml` contains minimal necessary resources to deploy a custom VPC with a public subnet
`work-node.yaml` - deploys an ec2 instance to the specified subnet. VM is accessible via SSH from the same IP.

The templates are stored in an S3 bucket `CF_TEMPLATE_BUCKET_NAME`, make sure this env is set before using make.
```sh
export CF_TEMPLATE_BUCKET_NAME=<bucket-name>
```
