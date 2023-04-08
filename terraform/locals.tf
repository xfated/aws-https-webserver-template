// Define local variables
locals {
    project_name = ""
    aws_region = ""
    domain_name = "crumbles.link"   
    subnets = [{
        name = "ap-southeast-1a",
        cidr_block = "10.0.0.0/19"
    }, 
    {
        name = "ap-southeast-1b",
        cidr_block = "10.0.32.0/19"
    }]
}