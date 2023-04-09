// Define local variables
locals {
  // project information
  project_name   = "aws-https-webserver"
  aws_region     = "ap-southeast-1"
  aws_account_id = "<your account id>"

  // ecr    
  ecr_repository_name = "aws-https-webserver"

  // ec2
  ec2_image_tag     = "https-webserver"
  ec2_key_pair_name = "<your key pair name>"

  // dns 
  domain_name = "<your domain>"
  public_subnets = { // Specifying 2 because AWS requires 2 subnet for 2 availabiltiy zone for creating a load balancer
    "subnet-1" : {
      "availability_zone" : "ap-southeast-1a",
      "cidr_block" : "10.0.0.0/19"
    },
    "subnet-2" : {
      "availability_zone" : "ap-southeast-1b",
      "cidr_block" : "10.0.32.0/19"
    }
  }
}