resource "aws_s3_bucket" "dzi_backup" {
  count    = terraform.workspace == "production" ? 1 : 0
  provider = aws.backup

  bucket = "${local.name_prefix}-dzi-backup"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    "service"        = "kithe"
    "use"            = "dzi"
    "S3-Bucket-Name" = "${local.name_prefix}-dzi-backup"
  }
}

resource "aws_s3_bucket_policy" "dzi_backup" {
  count    = terraform.workspace == "production" ? 1 : 0
  provider = aws.backup

  bucket = aws_s3_bucket.dzi_backup[0].id
  policy = templatefile("templates/s3_public_read_policy.tftpl", { bucket_name : aws_s3_bucket.dzi_backup[0].id })
}

resource "aws_s3_bucket_cors_configuration" "dzi_backup" {
  count  = terraform.workspace == "production" ? 1 : 0
  bucket = aws_s3_bucket.dzi_backup[0].id

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

resource "aws_s3_bucket_lifecycle_configuration" "dzi_backup" {
  count  = terraform.workspace == "production" ? 1 : 0
  bucket = aws_s3_bucket.dzi_backup[0].id

  rule {
    status = "Enabled"
    id     = "Expire previous files"

    expiration {
      days = 30
    }
  }
  rule {
    status = "Enabled"
    id     = "scihist-digicoll-production-dzi-backup-IA-Rule"

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "dzi_backup" {
  count  = terraform.workspace == "production" ? 1 : 0
  bucket = aws_s3_bucket.dzi_backup[0].id

  rule {
    bucket_key_enabled = false
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}