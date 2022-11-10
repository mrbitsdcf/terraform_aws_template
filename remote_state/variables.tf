variable "rules" {
  type        = list(map(string))
  description = "Rules for backup policy"
}

variable "backup_vault_name" {
  type        = string
  description = "Name for Backup Vault"
}
