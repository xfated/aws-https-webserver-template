#! /bin/bash
# Set vars
IMAGE_TAG=https-webserver
AWS_ACCOUNT_ID=<your account id>
ECR_REPOSITORY=aws-https-webserver
REGION=ap-southeast-1

set -e 

# login
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

# specify platform with buildx (depends on your ec2 instance)
docker buildx build --platform linux/amd64 --tag $IMAGE_TAG --build-arg PLACES_KEY=$PLACES_API_KEY .

# publish
docker tag $IMAGE_TAG $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$ECR_REPOSITORY:$IMAGE_TAG
docker push $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$ECR_REPOSITORY:$IMAGE_TAG