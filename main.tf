provider "aws" {
  region = var.region
}

provider "flux" {
  alias = "flux2-flux"
}

terraform {
  backend "s3" {
   bucket = "storage-state"
   key    = "storage-state/dev"
   region = "us-west-2"
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
  manage_aws_auth = false
  ##Test
  depends_on = [module.vpc]
  }
  
module "eks-node-gruop" {
  source = "umotif-public/eks-node-group/aws"
  version = "~> 4.0.0"
  cluster_name = module.eks.cluster_id
  node_group_name_prefix = var.node_group_name
  subnet_ids = module.vpc.public_subnets
  desired_size = var.desired_capacity
  min_size = var.min_size
  max_size = var.max_size
  instance_types = [var.instance_types]

}

module "flux" {
  source  = "app.terraform.io/Hypergiant/flux2-bootstrap/kubernetes"
  version = "~> 0.1.0"
  target_path = "${var.target_path}/${var.env}"
  repo_url = "https://github.com/${var.github_owner}/${var.repository_name}"
  branch = var.branch
  flux_token = var.flux_token
  bucket       = var.infra_bucket[var.env]
  key          = var.infra_file[var.env]
  region = var.region
  repo_provider = var.repo_provider
  components = var.components
  default_components = var.default_components
}

output "data_github"{
  value = module.flux2.data_github
}

##Pruebasss