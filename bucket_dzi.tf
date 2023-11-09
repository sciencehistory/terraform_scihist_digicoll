#
# DZI tiles, in a public bucket. They are voluminous
#
# Replication only in production.
resource "aws_s3_bucket" "dzi" {
  bucket = "${local.name_prefix}-dzi"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    "service"        = local.service_tag
    "use"            = "dzi"
    "S3-Bucket-Name" = "${local.name_prefix}-dzi"
  }
}

resource "aws_s3_bucket_replication_configuration" "dzi" {
  count  = terraform.workspace == "production" ? 1 : 0
  bucket = aws_s3_bucket.dzi.id
  role   = aws_iam_role.replication[0].arn
  rule {
    id       = "Backup"
    priority = 0
    status   = "Enabled"
    destination {
      bucket = aws_s3_bucket.dzi_backup[0].arn
    }
  }
}

resource "aws_s3_bucket_policy" "dzi" {
  bucket = aws_s3_bucket.dzi.id
  policy = templatefile("templates/s3_public_read_policy.tftpl", { bucket_name : aws_s3_bucket.dzi.id })
}

resource "aws_s3_bucket_cors_configuration" "dzi" {

  bucket = aws_s3_bucket.dzi.id

  cors_rule {
    allowed_headers = [
      "*",
    ]
    allowed_methods = [
      "GET",
    ]
    allowed_origins = [
      "*",
    ]
    expose_headers  = []
    max_age_seconds = 43200
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "dzi" {
  bucket = aws_s3_bucket.dzi.id

  rule {
    status = "Enabled"
    id     = "Expire previous files"

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }

  rule {
    status = "Enabled"
    id     = "scihist-digicoll-${terraform.workspace}-dzi-IT-Rule"

    transition {
      days          = 30
      storage_class = "INTELLIGENT_TIERING"
    }
  }
}

resource "aws_s3_bucket_versioning" "dzi" {
  bucket = aws_s3_bucket.dzi.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "dzi" {
  bucket = aws_s3_bucket.dzi.id

  rule {
    bucket_key_enabled = false
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}