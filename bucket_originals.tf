#
# Original assets, as ingested, in a private bucket
#
# Replication rule only for production.
#
resource "aws_s3_bucket" "originals" {
  bucket = "${local.name_prefix}-originals"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    "service"        = local.service_tag
    "use"            = "originals"
    "S3-Bucket-Name" = "${local.name_prefix}-originals"
  }

}


resource "aws_s3_bucket_replication_configuration" "originals" {
  count  = terraform.workspace == "production" ? 1 : 0
  bucket = aws_s3_bucket.originals.id
  role   = aws_iam_role.replication[0].arn
  rule {
    id       = "Backup"
    priority = 0
    status   = "Enabled"
    destination {
      bucket = aws_s3_bucket.originals_backup[0].arn
    }
  }
}


resource "aws_s3_bucket_public_access_block" "originals" {
  bucket = aws_s3_bucket.originals.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "originals" {
  bucket = aws_s3_bucket.originals.id

  rule {
    status = "Enabled"
    id     = "Expire previous files"

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }

  rule {
    status = "Enabled"
    id     = "scihist-digicoll-${terraform.workspace}-originals-IT-Rule"

    transition {
      days          = 30
      storage_class = "INTELLIGENT_TIERING"
    }
  }
}

resource "aws_s3_bucket_versioning" "originals" {
  bucket = aws_s3_bucket.originals.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "originals" {
  bucket = aws_s3_bucket.originals.id

  rule {
    bucket_key_enabled = false
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# LOGGING:


# terraform import aws_s3_bucket.chf-logs chf-logs
resource "aws_s3_bucket" "chf-logs" {
  force_destroy = false
  bucket        = "chf-logs"
  tags = {
    "Role"           = "Production"
    "S3-Bucket-Name" = "chf-logs"
    "Service"        = "Systems"
    "Type"           = "S3"
  }
}

# % terraform import aws_s3_bucket_logging.example bucket-name
resource "aws_s3_bucket_logging" "originals_logging" {
   bucket        = aws_s3_bucket.originals.id
   target_bucket = aws_s3_bucket.chf-logs.id
   target_prefix = "s3_server_access_${terraform.workspace}_originals/"
}