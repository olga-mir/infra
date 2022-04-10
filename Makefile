include Makefile.preflight

STACK_NAME=dev-infra-stack

.PHONY: deploy-stack
deploy-stack: check-setup
	$(if $(KeyName),,$(error KeyName please provide key name. 'make deploy-stack KeyName=<mykey>'))
	ImageID=$(or $(AMI_ID), $(shell aws ssm get-parameters --names /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 --region ${AWS_REGION} --query 'Parameters[0].[Value]' --output text)); \
	AdminCIDR=$(or $(AdminCIDR), $(shell curl -s https://checkip.amazonaws.com)/32); \
	aws cloudformation deploy --template-file infra-stack.yaml --stack-name ${STACK_NAME} --parameter-overrides ImageId=$$ImageID KeyName=$$KeyName AdminCIDR=$$AdminCIDR --capabilities CAPABILITY_IAM
	aws cloudformation describe-stacks --stack-name ${STACK_NAME} --query 'Stacks[0].Outputs[?OutputKey==`BastionPublicIP` || OutputKey==`WebServerPrivateIP`]'

.PHONY: get-ips
get-ips:
	aws cloudformation describe-stacks --stack-name ${STACK_NAME} --query 'Stacks[0].Outputs[?OutputKey==`BastionPublicIP` || OutputKey==`WebServerPrivateIP`]'

.PHONY: cleanup-all
cleanup-all:
	aws cloudformation delete-stack --stack-name ${STACK_NAME}
