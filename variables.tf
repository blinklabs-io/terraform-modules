variable "admins" {
  description = "List of KMS key admins"
  type        = list(string)
  default     = []
}

variable "aliases" {
  description = "List of aliases for KMS key"
  type        = list(string)
  default     = []
}

variable "description" {
  description = "KMS key description (required)"
  type        = string
}
