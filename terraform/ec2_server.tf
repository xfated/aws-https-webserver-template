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
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly" // The policy that provides ECR read access
}

resource "aws_iam_instance_profile" "ec2_profile" {
  role = aws_iam_role.ec2_role.name
}

// Creates an EC2 instance in each subnet (1 per availability zone)
//List of EC2 AMI can be found here: https://cloud-images.ubuntu.com/locator/ec2/
resource "aws_instance" "ec2_server_instance" {
  for_each = local.public_subnets

  ami                  = "ami-0f74c08b8b5effa56" // Select an AMI in your region
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name // Provide the role created above
  key_name             = local.ec2_key_pair_name                   // key-pair name for ssh

  subnet_id              = aws_subnet.public_subnets[each.key].id     // specify which subnet this instance is to be created in
  vpc_security_group_ids = [aws_security_group.vpc_security_group.id] // associate with security group ID of vpc

  user_data_replace_on_change = true // to force recreation of instance if you update user_data
  user_data = templatefile("./templates/webserver_init.tpl", {
    region         = local.aws_region
    aws_account_id = local.aws_account_id
    image_tag      = local.ec2_image_tag
    ecr_repository = local.ecr_repository_name
    machine_port   = 80
    docker_port    = 3000
  })

  tags = {
    Name = "${local.project_name}-web-server"
  }
}