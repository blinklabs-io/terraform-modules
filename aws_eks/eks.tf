data "aws_kms_alias" "ebs" {
  name = "alias/aws/ebs"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = var.cluster_version
  encryption_config  = var.encryption_config
  enable_irsa        = true

  # Disable default-enabled audit/api/authenticator logs
  enabled_log_types = []

  # Hardcoded to false
  # bootstrap_self_managed_addons = false
  addons = {
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_driver_irsa.arn
    }
    coredns = {
      addon_version     = "v1.11.4-eksbuild.2"
      resolve_conflicts = "OVERWRITE"
    }
    eks-pod-identity-agent = {
      addon_version     = "v1.3.5-eksbuild.2"
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {
      addon_version     = "v1.32.0-eksbuild.2"
      resolve_conflicts = "OVERWRITE"
    }
    vpc-cni = {
      addon_version     = "v1.19.2-eksbuild.5"
      resolve_conflicts = "OVERWRITE"
    }
  }

  endpoint_public_access = true

  # Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.public_subnets
  control_plane_subnet_ids = module.vpc.public_subnets

  tags = var.tags

  eks_managed_node_groups = {
    for ng_name, ng_conf in var.node_groups : ng_name => {
      name                 = "${var.cluster_name}-${ng_name}"
      launch_template_name = "${var.cluster_name}-${ng_name}-lt"
      ami_type             = try(ng_conf.ami_type, "AL2023_ARM_64_STANDARD")
      instance_type        = try(ng_conf.instance_type, "t4g.medium")
      min_size             = try(ng_conf.min_size, 0)
      max_size             = try(ng_conf.max_size, 2)
      desired_size = min(
        try(ng_conf.max_size, 2),
        try(ng_conf.desired_size, 0),
      )

      bootstrap_extra_args = (
        length(lookup(ng_conf, "kubelet_extra_args", "")) > 0 ?
        "--kubelet-extra-args \"${lookup(ng_conf, "kubelet_extra_args", "")}\""
        : ""
      )

      autoscaling_group_tags = try(ng_conf.autoscaling_group_tags, {})

      # public IP and single subnet (for now)
      subnet_ids = [module.vpc.public_subnets[0]]

      network_interfaces = [{
        device_index                = 0
        associate_public_ip_address = true
      }]

      metadata_options = try(ng_conf.metadata_options, null)

      # Encrypt the root disk
      block_device_mappings = {
        root = {
          device_name = "/dev/xvda"
          ebs = {
            delete_on_termination = true
            encrypted             = true
            kms_key_id            = data.aws_kms_alias.ebs.target_key_arn
            volume_size           = 100
            volume_type           = "gp3"
          }
        }
      }
      # Add tags to the autoscaling group
      tags = try(ng_conf.tags, {})
    }
  }
}

module "ebs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "~> 6.0"

  name            = "${var.cluster_name}-ebs-csi-driver"
  use_name_prefix = true

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = var.tags
}
