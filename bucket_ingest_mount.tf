#
# S3 bucket that is "mounted" on windows desktops, so staff can copy files to it, for later
# ingest by app.
#
resource "aws_s3_bucket" "ingest_mount" {
  bucket = "${local.name_prefix}-ingest-mount"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    "service"        = local.service_tag
    "use"            = "upload"
    "S3-Bucket-Name" = "${local.name_prefix}-ingest-mount"
  }



}

resource "aws_s3_bucket_public_access_block" "ingest_mount" {
  bucket = aws_s3_bucket.ingest_mount.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_cors_configuration" "ingest_mount" {

  bucket = aws_s3_bucket.ingest_mount.id

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

resource "aws_s3_bucket_lifecycle_configuration" "ingest_mount" {
  bucket = aws_s3_bucket.ingest_mount.id

  rule {
    status = "Disabled"
    id     = "Expire files"

    expiration {
      days                         = 30
      expired_object_delete_marker = false
    }
  }

  rule {
    status = "Enabled"
    id     = "scihist-digicoll-${terraform.workspace}-ingest-mount-IA-Rule"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}

resource "aws_s3_bucket_versioning" "ingest_mount" {
  bucket = aws_s3_bucket.ingest_mount.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ingest_mount" {
  bucket = aws_s3_bucket.ingest_mount.id

  rule {
    bucket_key_enabled = false
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
