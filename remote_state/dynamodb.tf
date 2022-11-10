resource "aws_kms_key" "aws_dynamodb_key" {
  description             = "AWS DynamoDB KMS key"
  deletion_window_in_days = 30
  enable_key_rotation     = true
}

resource "aws_dynamodb_table" "lock_table" {
  name           = format("%s-dynamodb", local.prefix)
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"
  tags           = local.common_tags

  attribute {
    name = "LockID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.aws_dynamodb_key.arn
  }
}
