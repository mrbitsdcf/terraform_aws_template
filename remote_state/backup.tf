resource "aws_iam_role" "aws-backup-service-role" {
  name               = "AWSBackupServiceRole"
  description        = "Allows the AWS Backup Service to take scheduled backups"
  assume_role_policy = data.aws_iam_policy_document.aws-backup-service-assume-role-policy.json
}

resource "aws_iam_role_policy_attachment" "backup-service-aws-backup-role-policy" {
  policy_arn = data.aws_iam_policy.aws-backup-service-policy.arn
  role       = aws_iam_role.aws-backup-service-role.name
}

resource "aws_iam_role_policy_attachment" "restore-service-aws-backup-role-policy" {
  policy_arn = data.aws_iam_policy.aws-restore-service-policy.arn
  role       = aws_iam_role.aws-backup-service-role.name
}

resource "aws_kms_key" "aws_backup_key" {
  description             = "AWS Backup KMS key"
  deletion_window_in_days = 7
  enable_key_rotation     = false
}

resource "aws_backup_vault" "backup-vault" {
  name        = format("%s-remote-state", var.backup_vault_name)
  kms_key_arn = aws_kms_key.aws_backup_key.arn
  tags = {
    Role = "backup-vault"
  }
}

resource "aws_backup_plan" "backup-plan" {
  name = "${var.backup_vault_name}_plan"
  dynamic "rule" {
    for_each = var.rules
    content {
      rule_name                = lookup(rule.value, "name", null)
      target_vault_name        = aws_backup_vault.backup-vault.name
      schedule                 = lookup(rule.value, "schedule", null)
      start_window             = lookup(rule.value, "start_window", null)
      completion_window        = lookup(rule.value, "completion_window", null)
      enable_continuous_backup = lookup(rule.value, "enable_continuous_backup", null)
      recovery_point_tags = {
        Frequency  = lookup(rule.value, "name", null)
        Created_By = "aws-backup"
      }
      lifecycle {
        delete_after = lookup(rule.value, "delete_after", null)
      }
    }
  }
}

resource "aws_backup_selection" "backup-selection" {
  iam_role_arn = aws_iam_role.aws-backup-service-role.arn
  name         = "backup_resources"
  plan_id      = aws_backup_plan.backup-plan.id

  resources = [
    aws_s3_bucket.remote_state.arn
  ]
}
