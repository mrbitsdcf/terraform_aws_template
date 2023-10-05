output "dynamodb-lock-table" {
  value       = aws_dynamodb_table.lock_table.name
  description = "DynamoDB table for Terraform execution locks"
}

output "dynamodb-lock-table-ssm-parameter" {
  value       = format("%s/tf-locks-table-arn", local.ssm_prefix)
  description = "SSM parameter containing DynamoDB table for Terraform execution locks"
}

output "s3-state-bucket" {
  value       = aws_s3_bucket.remote_state.id
  description = "S3 bucket for storing Terraform state"
}

output "s3-state-bucket-ssm-parameter" {
  value       = format("%s/tf-remote-state-bucket", local.ssm_prefix)
  description = "SSM parameter containing S3 bucket for storing Terraform state"
}

output "s3-iam-service-user-keys" {
  value       = aws_iam_access_key.iam_access_key
  description = "IAM user access and secret keys"
  sensitive   = true
}
