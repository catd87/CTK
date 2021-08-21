provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
   
  }
}

data "aws_availability_zones" "available" {
 state= "available"
 }

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name            = "${var.env}-${var.vpcname}"
  cidr            = var.vpc_cidr  
  azs             = data.aws_availability_zones.available.names
  private_subnets = var.subn_private
  public_subnets  = var.subn_public
  
  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "prod"
  }

}

output "vpc" {
  value = module.vpc
  
  }




module "eks" {
  source = "terraform-aws-modules/eks/aws"
  cluster_name = "${var.env}-${var.cluster_name}"
  vpc_id       = module.vpc.vpc_id
  subnets      = module.vpc.public_subnets
  cluster_version = var.cluster_version
  
 
  node_groups = {
    eks_nodes = {
      desired_capacity = 2
      max_capacity     = 2
      min_capaicty     = 2
 
      instance_type = "t2.micro"
    }
  }
  manage_aws_auth = false

  depends_on = [
    module.vpc
      ]
}