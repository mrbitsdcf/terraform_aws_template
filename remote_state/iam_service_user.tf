resource "aws_iam_user" "s3_service_user" {
  count = var.create_iam_service_user ? 1 : 0
  name  = "s3_iam_service_user_tfstate"
}

resource "aws_iam_access_key" "iam_access_key" {
  count = var.create_iam_service_user ? 1 : 0
  user  = aws_iam_user.s3_service_user.name
}

resource "aws_iam_policy" "s3_iam_policy" {
  count       = var.create_iam_service_user ? 1 : 0
  name        = "s3-tfstate-service-user-policy"
  description = "Policy to allow IAM user to access S3 Bucket and DynamoDB table that stores terraform state file and controls file locking"

  policy = templatefile(
    "iam_user_policy.tftpl",
    {
      "policy_id"          = "s3-tfstate-service-user-policy"
      "s3_bucket_arn"      = aws_s3_bucket.remote_state.arn
      "dynamodb_table_arn" = aws_dynamodb_table.lock_table.arn
    }
  )
}

resource "aws_iam_user_policy_attachment" "test-attach" {
  count      = var.create_iam_service_user ? 1 : 0
  user       = aws_iam_user.s3_service_user.name
  policy_arn = aws_iam_policy.s3_iam_policy.arn
}
