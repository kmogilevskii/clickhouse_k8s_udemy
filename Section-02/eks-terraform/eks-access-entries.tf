# module "cluster_admin_role" {
#   source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
#   version = "5.39.1"

#   create_role                       = true
#   role_name                         = "FXCAmazonEKSClusterAdminRole"
#   role_requires_mfa                 = false
#   number_of_custom_role_policy_arns = 0
#   trusted_role_arns                 = [
#     "arn:aws:iam::{account_id}:user/kmogilevskii",
#     "arn:aws:iam::{account_id}:user/username",
#   ]
# }

# module "viewonly_role" {
#   source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
#   version = "5.39.1"

#   create_role                       = true
#   role_name                         = "FXCAmazonEKSViewRole"
#   role_requires_mfa                 = false
#   number_of_custom_role_policy_arns = 0
#   trusted_role_arns                 = [
#     "arn:aws:iam::{account_id}:user/kmogilevskii"
#   ]
# }