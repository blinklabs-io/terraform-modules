output "vpc" {
  value = module.vpc
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "oidc_provider" {
  value = module.eks.oidc_provider
}

output "external_dns_iam_role_arn" {
  value = var.enable_external_dns ? module.external_dns_irsa[0].iam_role_arn : null
}
