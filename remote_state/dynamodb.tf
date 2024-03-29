resource "aws_dynamodb_table" "lock_table" {
  name           = format("%s-dynamodb", local.main_project)
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"
  tags           = local.common_tags

  attribute {
    name = "LockID"
    type = "S"
  }
}
