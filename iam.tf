module "iam_aws_lb_controller" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "~> 6.0"

  name = "${var.cluster_name}-aws-lb-controller"
  # v6 of iam-role-for-service-accounts defaults use_name_prefix to true, which
  # appends a random suffix to the role name. Force the literal name so the role
  # ARN is stable and can be referenced by downstream IRSA ServiceAccount
  # annotations (e.g. aws-load-balancer-controller).
  use_name_prefix = false

  attach_load_balancer_controller_policy = true

  // We need StringLike to use * in the namespace_service_accounts
  trust_condition_test = "StringLike"

  oidc_providers = {
    one = {
      provider_arn = module.eks.oidc_provider_arn
      namespace_service_accounts = [
        "kube-system:*",
      ]
    }
  }
}

module "external_dns_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "~> 6.0"

  count = var.enable_external_dns ? 1 : 0

  name = "${var.cluster_name}-external-dns"
  # v6 of iam-role-for-service-accounts defaults use_name_prefix to true, which
  # appends a random suffix to the role name. Force the literal name so the role
  # ARN is stable and can be referenced by the external-dns Helm release IRSA
  # ServiceAccount annotation. Without this, sts:AssumeRoleWithWebIdentity
  # fails with 403 AccessDenied because the consumer references a role name
  # that does not exist.
  use_name_prefix = false

  attach_external_dns_policy = true

  // We need StringLike to use * in the namespace_service_accounts
  trust_condition_test = "StringLike"

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:*"]
    }
  }

  external_dns_hosted_zone_arns = var.external_dns_hosted_zone_arns
  tags                          = var.tags
}
