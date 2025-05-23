# This file contains the configuration for creating an S3 bucket and a DynamoDB table
# to be used as a backend for Terraform state management.

resource "aws_s3_bucket" "tf_state" {
  bucket = "tfstate-bucket-${data.aws_caller_identity.me.account_id}"
  force_destroy = false

  lifecycle {
    prevent_destroy = true
  }
}

# Versioning configuration for the S3 bucket
# to ensure that the state file is versioned and can be restored if needed.
resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Encryption configuration for the S3 bucket
# to ensure that the state file is stored securely.
resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Table for locking the state file to prevent concurrent operations
resource "aws_dynamodb_table" "tf_lock" {
  name         = "tfstate-lock-table-${data.aws_caller_identity.me.account_id}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
