# Deploying a docker image to Amazon ECR

1. Build your web server. Simple example in [src](./src/)
1. Write a Dockerfile with instructions to build your docker image. Instuctions from [nodejs.org](https://nodejs.org/en/docs/guides/nodejs-docker-webapp)
    - Add a .dockerignore file to prevent local modules and debug logs from being copied to your Docker image
1. Create an ECR registry to store your web server images. Tutorial found [here](https://docs.aws.amazon.com/AmazonECR/latest/userguide/repository-create.html)
1. Examples for building and running your docker image can be found on the [nodejs.org site](https://nodejs.org/en/docs/guides/nodejs-docker-webapp) as well. Have provided 2 scripts for the commands.
    - [build.sh](./build.sh)
        ```bash
        IMAGE_TAG=https-webserver 

        docker build --tag $IMAGE_TAG .
        ```
    - [run.sh](./run.sh)
        ```bash
        IMAGE_TAG=https-webserver 

        docker run -p 3000:3000 $IMAGE_TAG 
        ```
        - To test that it works, you can run the image and access localhost:3000 on your browser
1. Publishing your image to ECR. Detailed instructions provided in [AWS Documentation](https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-ecr-image.html).
    ```bash
    # Set vars
    IMAGE_TAG=https-webserver
    AWS_ACCOUNT_ID=<your aws account id>
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
    ```
    - For build, we use the `docker buildx build` command to specify the platform we want to build for. As I'm running on mac os, simply running docker build will create a container for the linux/arm64 architeture. As my ec2 instance will be using amd64, I have to specify a different platform for the build here.