variable "vpcname" {
  type = string
  default = "vpc_name"
}
variable "env" {
  type = string
  }
variable "cluster_name" {
  type = string
  default = "cluster"
}

 variable "region" {
  type =  string
  default = "us-west-2"
}


variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
 }

variable "subn_private" {
  description = "subnets"
  type        = list 
  }
variable "subn_public" {
  description = "subnets"
  type        = list 
}
variable "cluster_version"{
   type = string
 }