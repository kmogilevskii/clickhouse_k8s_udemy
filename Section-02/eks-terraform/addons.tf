module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.16.2"

  depends_on = [module.eks]

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  eks_addons = {
    aws-ebs-csi-driver = {
      service_account_role_arn = aws_iam_role.ebs_csi_driver_role.arn
    }
  }

  enable_aws_load_balancer_controller = true
  aws_load_balancer_controller = {
    namespace = "kube-system"
    values = [templatefile("${path.module}/load-balancer-controller.yaml.tpl", {
      vpc_id = module.vpc.vpc_id,
      aws_region         = var.region,
      eks_cluster_id     = module.eks.cluster_name,
    })]
  }

  enable_external_dns = true
  external_dns = {}
  external_dns_route53_zone_arns = ["arn:aws:route53:::hostedzone/Z04140322IWVE54VCYDEB"]
}

resource "kubernetes_storage_class" "gp3-encrypted" {
  depends_on = [module.eks_blueprints_addons]

  metadata {
    name = "gp3-encrypted"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner = "ebs.csi.aws.com"

  parameters = {
    encrypted = "true"
    fsType    = "ext4"
    type      = "gp3"
  }

  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
}

resource "kubernetes_annotations" "disable_gp2" {
  depends_on = [module.eks_blueprints_addons]
  annotations = {
    "storageclass.kubernetes.io/is-default-class" : "false"
  }

  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  metadata {
    name = "gp2"
  }

  force = true
}