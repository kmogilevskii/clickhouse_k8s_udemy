locals {
  account_id = data.aws_caller_identity.current.account_id

  subnets = var.enable_nat_gateway ? module.vpc.private_subnets : module.vpc.public_subnets
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.8.4"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = local.subnets

  enable_cluster_creator_admin_permissions = true
  create_iam_role                          = false
  iam_role_arn                             = aws_iam_role.eks_cluster_role.arn

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
  }

  eks_managed_node_groups = {

    clickhouse = {
      min_size    = 4
      max_size     = 4
      desired_size = 4

      instance_types = ["t3.large"]
      disk_size      = 5

      subnet_ids = local.subnets

      name            = "clickhouse"
      use_name_prefix = true

      iam_role_use_name_prefix = false
      create_iam_role          = false
      iam_role_arn             = aws_iam_role.eks_node_role.arn

      tags = var.tags
    }

    zookeeper = {
      min_size    = 3
      max_size     = 3
      desired_size = 3

      instance_types = ["t2.large"]
      disk_size      = 5

      subnet_ids = local.subnets

      name            = "zookeeper"
      use_name_prefix = true

      iam_role_use_name_prefix = false
      create_iam_role          = false
      iam_role_arn             = aws_iam_role.eks_node_role.arn

      tags = var.tags
    }

  }

  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = var.public_access_cidrs

#   access_entries = {
#     admin = {
#       kubernetes_groups = []
#       principal_arn     = module.cluster_admin_role.iam_role_arn

#       policy_associations = {
#         admin = {
#           policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
#           access_scope = {
#             type       = "cluster"
#           }
#         }
#       }
#     }

#     viewonly = {
#       kubernetes_groups = []
#       principal_arn     = module.viewonly_role.iam_role_arn

#       policy_associations = {
#         viewonly = {
#           policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
#           access_scope = {
#             type       = "cluster"
#           }
#         }
#       }
#     }
#   }


  tags = var.tags
}