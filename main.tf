module "kms" {
  source = "terraform-aws-modules/kms/aws"

  description = var.description

  # Policy
  key_administrators = var.admins

  # Aliases
  aliases = var.aliases

  deletion_window_in_days = 7
  enable_key_rotation     = true
}
