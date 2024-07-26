################################################################################
# Global
################################################################################

variable "region" {
  description = "The AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "tags" {
  description = "Map with AWS tags"
  type        = map(string)
  default     = {
    "udemy"       = "1"
    "project"     = "clickhouse"
    "managed_by"   = "terraform"
  }

}

################################################################################
# VPC
################################################################################

variable "cidr" {
  description = "CIDR block"
  type        = string
  default     = "10.4.0.0/16"
}

variable "private_cidr" {
  description = "List of private CIDR blocks (one block per availability zones)"
  type        = list(string)
  default = ["10.4.10.0/24", "10.4.11.0/24", "10.4.12.0/24"]
}

variable "public_cidr" {
  description = "List of public CIDR blocks (one block per availability zones)"
  type        = list(string)
  default = ["10.4.1.0/24", "10.4.2.0/24", "10.4.3.0/24"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway and private subnets (recommeded)"
  type        = bool
  default     = true
}

################################################################################
# EKS
################################################################################

variable "cluster_name" {
  description = "The name of the cluster"
  type        = string
  default     = "clickhouse"
}

variable "cluster_version" {
  description = "Version of the cluster"
  type        = string
  default     = "1.29"
}

variable "public_access_cidrs" {
  description = "List of CIDRs for public access, use this variable to restrict access to the EKS control plane."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}