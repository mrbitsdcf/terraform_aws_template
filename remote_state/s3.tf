resource "aws_s3_bucket" "remote_state" {
  bucket        = format("%s-%s-%s", local.main_project, local.aws_region, local.aws_account)
  force_destroy = true

  tags = merge(
    local.common_tags,
    {
      "Backup" = "True"
    }
  )
}

resource "aws_s3_bucket_public_access_block" "s3public_remote_state" {
  depends_on              = [aws_s3_bucket_policy.remote_state_policy]
  bucket                  = aws_s3_bucket.remote_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "remote_state_policy" {
  bucket = aws_s3_bucket.remote_state.id

  policy = <<POLICY
{
    "Version": "2008-10-17",
    "Statement": [
        {
          "Sid": "DenyInsecureAccess",
          "Effect": "Deny",
          "Principal": "*",
          "Action": "s3:*",
          "Resource": [
            "${aws_s3_bucket.remote_state.arn}",
            "${aws_s3_bucket.remote_state.arn}/*"
          ],
          "Condition": {
            "Bool": {
              "aws:SecureTransport": "false"
            }
          }
        },
        {
          "Sid": "EnforceEncryption",
          "Effect": "Deny",
          "Principal": "*",
          "Action": "s3:PutObject",
          "Resource": [
            "${aws_s3_bucket.remote_state.arn}/*"
          ],
          "Condition": {
            "StringNotEquals": {
              "s3:x-amz-server-side-encryption": "AES256"
            }
          }
        },
        {
          "Sid": "DenyUnencryptedObjectUploads",
          "Effect": "Deny",
          "Principal": "*",
          "Action": "s3:PutObject",
          "Resource": [
            "${aws_s3_bucket.remote_state.arn}/*"
          ],
          "Condition": {
            "Null": {
              "s3:x-amz-server-side-encryption": "true"
            }
          }
        }
    ]
}
POLICY

}

resource "aws_s3_bucket_versioning" "remote_state_versioning" {
  bucket = aws_s3_bucket.remote_state.id

  versioning_configuration {
    status = "Enabled"
  }
}
