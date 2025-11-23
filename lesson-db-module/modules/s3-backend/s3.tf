resource "aws_s3_bucket" "tf_state" {
  bucket = var.bucket_name
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    id      = "prevent-delete"
    enabled = true

    noncurrent_version_expiration {
      days = 90
    }
  }

  tags = merge(var.tags, {
    Name = "${var.bucket_name}"
    Type = "terraform-state"
  })
}

# Block public access
resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.tf_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

