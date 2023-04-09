#! /bin/bash
# Download docker
sudo apt update
sudo apt install docker.io -y
sudo apt install unzip

# Download aws cli to get authentication 
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Pull your image
aws ecr get-login-password --region ${region} | docker login --username AWS --password-stdin ${aws_account_id}.dkr.ecr.${region}.amazonaws.com
docker pull ${aws_account_id}.dkr.ecr.${region}.amazonaws.com/${ecr_repository}:${image_tag}

# run your image, mapping port 80 (default HTTP) on the machine to port 3000 (or where your server is listening) of your docker container
docker run -d -p ${machine_port}:${docker_port} ${aws_account_id}.dkr.ecr.${region}.amazonaws.com/${ecr_repository}:${image_tag}