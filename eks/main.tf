locals {
  prefix          = "dev"
  infix           = "useast1-eks"
  suffix          = "1"
  jira-ticket     = "OPS-123"
  region          = "us-east-1"
  cluster_version = "1.31"
  cluster_name    = "${local.prefix}-${local.infix}-${local.suffix}"
  tags = {
    cluster = local.cluster_name
  }
}

# EKS
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~>20.0"

  cluster_name    = local.cluster_name
  cluster_version = local.cluster_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets
  tags            = local.tags

  cluster_endpoint_public_access = true
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    aws-ebs-csi-driver = {
      service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
    }
  }

  # EKS Managed Nodes as part of eks module
  eks_managed_node_group_defaults = {
    ami_type                   = "AL2_x86_64"
    iam_role_attach_cni_policy = true
  }

  eks_managed_node_groups = {
    userpool = {
      name = "userpool-1"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }

    spotpool = {
      name = "spotcore"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }
}
