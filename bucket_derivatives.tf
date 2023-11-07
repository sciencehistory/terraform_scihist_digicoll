resource "aws_s3_bucket" "derivatives" {
  bucket = "${local.name_prefix}-derivatives"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    "service"        = local.service_tag
    "use"            = "derivatives"
    "S3-Bucket-Name" = "${local.name_prefix}-derivatives"
  }
}

resource "aws_s3_bucket_replication_configuration" "derivatives" {
  count  = terraform.workspace == "production" ? 1 : 0
  bucket = aws_s3_bucket.derivatives.id
  role   = aws_iam_role.S3-Backup-Replication.arn
  rule {
    id       = "Backup"
    priority = 0
    status   = "Enabled"
    destination {
      bucket = aws_s3_bucket.derivatives_backup[0].arn
    }
  }
}

resource "aws_s3_bucket_policy" "derivatives" {
  bucket = aws_s3_bucket.derivatives.id
  policy = templatefile("templates/s3_public_read_policy.tftpl", { bucket_name : aws_s3_bucket.derivatives.id })
}

resource "aws_s3_bucket_cors_configuration" "derivatives" {

  bucket = aws_s3_bucket.derivatives.id

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


resource "aws_s3_bucket_lifecycle_configuration" "derivatives" {
  bucket = aws_s3_bucket.derivatives.id
  rule {
    status = "Enabled"
    id     = "Expire previous files"

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
  rule {
    status = "Enabled"
    id     = "scihist-digicoll-${terraform.workspace}-derivatives-IT-Rule"

    transition {
      days          = 30
      storage_class = "INTELLIGENT_TIERING"
    }
  }
}


resource "aws_s3_bucket_versioning" "derivatives" {
  bucket = aws_s3_bucket.derivatives.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "derivatives" {
  bucket = aws_s3_bucket.derivatives.id

  rule {
    bucket_key_enabled = false
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
