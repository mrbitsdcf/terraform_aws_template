variable "rules" {
  type        = list(map(string))
  description = "Rules for backup policy"
}

variable "backup_vault_name" {
  type        = string
  description = "Name for Backup Vault"
}

variable "create_iam_service_user" {
  type        = boolean
  description = "Whether to create an IAM user with permissions in S3 bucket and DynamoDB table, to be used with IaC pipelines"
  default     = false
}
