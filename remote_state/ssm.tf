resource "aws_ssm_parameter" "locks_table_arn" {
  name      = format("%s/tf-locks-table-arn", local.ssm_prefix)
  type      = "String"
  value     = aws_dynamodb_table.lock_table.arn
  overwrite = false

  lifecycle {
    ignore_changes = [
      value,
    ]
  }

  tags = local.common_tags
}


resource "aws_ssm_parameter" "remote_state_bucket" {
  name      = format("%s/tf-remote-state-bucket", local.ssm_prefix)
  type      = "String"
  value     = aws_s3_bucket.remote_state.id
  overwrite = false

  lifecycle {
    ignore_changes = [
      value,
    ]
  }

  tags = local.common_tags
}
