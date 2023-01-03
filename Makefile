include Makefile.preflight

STACK_NAME=dev-infra-stack

.PHONY: lint
lint:
	cfn-lint infra-stack.yaml

.PHONY: deploy-stack
deploy-stack: lint check-setup
	ImageID=$(or $(ImageID), $(shell aws ssm get-parameters --names /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 --region ${AWS_REGION} --query 'Parameters[0].[Value]' --output text)); \
	aws cloudformation deploy --template-file infra-stack.yaml --stack-name ${STACK_NAME} --parameter-overrides ImageId=$$ImageID InstanceType=c6i.2xlarge --capabilities CAPABILITY_IAM

.PHONY: deploy-stack-arm
deploy-stack-arm: lint check-setup
	ImageID=$(or $(ImageID), $(shell aws ssm get-parameters --names /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-arm64-gp2 --region ${AWS_REGION} --query 'Parameters[0].[Value]' --output text)); \
	aws cloudformation deploy --template-file infra-stack.yaml --stack-name ${STACK_NAME} --parameter-overrides ImageId=ami-09cf60dc4c078303c InstanceType=c7g.2xlarge --capabilities CAPABILITY_IAM

.PHONY: get-info
get-info:
	aws cloudformation describe-stacks --stack-name ${STACK_NAME} --query 'Stacks[0].Outputs[?OutputKey==`WorkNodePrivateIP` || OutputKey==`WorkNodeInstanceId`]'

.PHONY: deploy
deploy: check-setup lint deploy-stack get-info

.PHONY: deploy-arm
deploy-arm: check-setup lint deploy-stack-arm get-info

.PHONY: cleanup-all
cleanup-all:
	aws cloudformation delete-stack --stack-name ${STACK_NAME}


#  aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query 'Reservations[].Instances[].InstanceId' --output=text
# aws ssm get-parameters-by-path \
    --path /aws/service/ami-amazon-linux-latest \
    --query 'Parameters[].Name'
