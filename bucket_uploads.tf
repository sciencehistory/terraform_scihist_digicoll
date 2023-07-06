#
# A bucket to which our app's in-browser javascript uploads files to be ingested, so the
# back-end app can get them. Should NOT be public. Needs CORS tags to allow JS upload.
#
resource "aws_s3_bucket" "uploads" {
  bucket = "${local.name_prefix}-uploads"

  lifecycle {
    prevent_destroy = true
    # Workaround:
    # See https://github.com/hashicorp/terraform-provider-aws/issues/25241
    # Can remove this ignore_changes after we move to AWS Provider 4.x
    ignore_changes = [
      cors_rule,
      lifecycle_rule
    ]
  }

  tags = {
    "service"        = local.service_tag
    "use"            = "upload"
    "S3-Bucket-Name" = "${local.name_prefix}-uploads"
  }
}

resource "aws_s3_bucket_public_access_block" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_cors_configuration" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  cors_rule {
    allowed_headers = [
      "Authorization",
      "x-amz-date",
      "x-amz-content-sha256",
      "content-type",
    ]
    allowed_methods = [
      "GET",
      "POST",
      "PUT",
    ]
    allowed_origins = [
      "*",
    ]
    expose_headers = [
      "ETag",
    ]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  rule {
    status = "Enabled"
    id     = "Expire files"

    expiration {
      days = 30
      expired_object_delete_marker = false
    }
  }

  rule {
    status = "Enabled"
    id     = "scihist-digicoll-${terraform.workspace}-uploads-IA-Rule"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}

resource "aws_s3_bucket_versioning" "uploads" {
  bucket = aws_s3_bucket.uploads.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  rule {
    bucket_key_enabled = false
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
