data "aws_availability_zones" "available" {
    state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.8.1"

  name = "${var.cluster_name}-vpc"
  cidr = var.cidr
  azs  = data.aws_availability_zones.available.names

  public_subnets = var.public_cidr
  # ⚠️ If NAT gateway is disabled, your EKS nodes will automatically run under public subnets.
  private_subnets = var.enable_nat_gateway ? var.private_cidr : []

  map_public_ip_on_launch = !var.enable_nat_gateway
  enable_vpn_gateway      = true
  enable_nat_gateway      = var.enable_nat_gateway
  single_nat_gateway      = true

  tags = var.tags

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1",
    "kubernetes.io/cluster/clickhouse" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1",
    "kubernetes.io/cluster/clickhouse" = "shared"
  }
}