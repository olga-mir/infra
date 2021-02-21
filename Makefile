CF_TEMPLATE_BUCKET_S3_URI=s3://${CF_TEMPLATE_BUCKET_NAME}/${CF_TEMPLATE_PATH}
CF_TEMPLATE_BUCKET_URL=https://${CF_TEMPLATE_BUCKET_NAME}.s3-${AWS_REGION}.amazonaws.com/${CF_TEMPLATE_PATH}

.PHONY: debug
debug:
	echo CF_TEMPLATE_PATH: ${CF_TEMPLATE_PATH}
	echo CF_TEMPLATE_BUCKET_S3_URI ${CF_TEMPLATE_BUCKET_S3_URI}
	echo CF_TEMPLATE_BUCKET_URL ${CF_TEMPLATE_BUCKET_URL}

.PHONY: init-bucket
init-bucket:
	aws s3 mb ${CF_TEMPLATE_BUCKET_S3_URI} --region ${AWS_REGION}

.PHONY: deploy-network
deploy-network:
	aws s3 cp network-setup.yaml s3://${CF_TEMPLATE_BUCKET_NAME}/network-setup.yaml
	aws cloudformation create-stack --stack-name public-subnet --template-url  https://${CF_TEMPLATE_BUCKET_NAME}.s3-${AWS_REGION}.amazonaws.com/network-setup.yaml --parameters VpcId=${VPC_ID}

.PHONY: deploy-work-node
deploy-work-node:
	aws s3 cp work-node.yaml s3://${CF_TEMPLATE_BUCKET_NAME}/work-node.yaml
	MY_IP=$(shell curl -s https://checkip.amazonaws.com); \
  aws cloudformation create-stack --stack-name cks-work-node --template-url https://${CF_TEMPLATE_BUCKET_NAME}.s3-${AWS_REGION}.amazonaws.com/work-node.yaml --parameters ParameterKey=SshSourceCidr,ParameterValue=$$MY_IP/32

.PHONY: get-ips
get-ips:
	aws ec2 describe-instances \
	--filters "Name=instance-state-name,Values=running" \
	--region=${AWS_REGION} \
	--query 'Reservations[*].Instances[*].[PrivateIpAddress, PublicIpAddress]' \
	--output text

.PHONY: cleanup-all
cleanup-all:
	aws cloudformation delete-stack --stack-name cks-work-node
	aws cloudformation delete-stack --stack-name public-subnet

.PHONY: cleanup-node
cleanup-node:
	aws cloudformation delete-stack --stack-name cks-work-node
