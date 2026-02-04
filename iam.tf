module "iam_aws_lb_controller" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  name   = "${var.cluster_name}-aws-lb-controller"

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
