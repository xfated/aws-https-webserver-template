// Create a role that enables you to pull your image from the ECR into EC2
resource "aws_iam_role" "ec2_role" {
  path               = "/"
  assume_role_policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": "sts:AssumeRole",
                "Principal": {
                "Service": "ec2.amazonaws.com"
                },
                "Effect": "Allow",
                "Sid": ""
            }
        ]
    }
    EOF
}

resource "aws_iam_role_policy_attachment" "ec2_profile_attachment" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly" // The policy that provides ECR read access
}

resource "aws_iam_instance_profile" "ec2_profile" {
  role = aws_iam_role.role.name
}

// Create your instance 
resource "aws_instance" "ec2_server_instance" {
  ami           = "ami-0f74c08b8b5effa56" // Select an AMI in your region
  instance_type = "t2.micro"              
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name // Provide the role created above
  key_name      = "crumble-server" // key-pair name

  subnet_id                   = var.subnet_id // specify which subnet this instance is to be created in
  vpc_security_group_ids      = [var.vpc_security_group_id]  // associate with security group ID of vpc

  user_data_replace_on_change = true // to force recreation of instance if you update user_data
  user_data = <<-EOF
    #! /bin/bash
    sudo apt update
    sudo apt install docker.io -y
    sudo apt install unzip
    
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install

    # Pull
    aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin 552747892778.dkr.ecr.ap-southeast-1.amazonaws.com
    docker pull 552747892778.dkr.ecr.ap-southeast-1.amazonaws.com/crumble-container-registry:crumble-backend

    docker run -d -p 80:3000 552747892778.dkr.ecr.ap-southeast-1.amazonaws.com/crumble-container-registry:crumble-backend
    EOF

  tags = {
    Name = "${local.project-name}-web-server"
  }
}