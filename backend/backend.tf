variable "bucket_name" {
  default = "dzenrei-tfstate-bucket"
}

# S3 backend configuration for Terraform state management
resource "aws_s3_bucket" "tf_state" {
  bucket = var.bucket_name
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
