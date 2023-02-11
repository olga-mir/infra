include Makefile.preflight

STACK_NAME=dev-infra-stack

.PHONY: lint
lint:
	cfn-lint infra-stack.yaml


.PHONY: deploy-stack
deploy-stack: lint check-setup
	ImageID=$(or $(ImageID), $(shell aws ssm get-parameters --names /aws/service/ami-amazon-linux-latest/al2022-ami-kernel-5.15-x86_64 --region ${AWS_REGION} --query 'Parameters[0].[Value]' --output text)); \
	aws cloudformation deploy --template-file infra-stack.yaml --stack-name ${STACK_NAME} --parameter-overrides ImageId=$$ImageID --capabilities CAPABILITY_IAM


.PHONY: get-info
get-info:
	aws cloudformation describe-stacks --stack-name ${STACK_NAME} --query 'Stacks[0].Outputs[?OutputKey==`WorkNodePrivateIP` || OutputKey==`WorkNodeInstanceId`]'


.PHONY: deploy
deploy: check-setup lint deploy-stack get-info


.PHONY: connect
connect:
	aws ssm start-session --target $(shell aws cloudformation describe-stacks --stack-name ${STACK_NAME} --query 'Stacks[0].Outputs[?OutputKey==`WorkNodeInstanceId`].OutputValue' --output text)


.PHONY: cleanup
cleanup:
	aws cloudformation delete-stack --stack-name ${STACK_NAME}
