#
# Original VIDEO assets, as ingested, in a private bucket, separate bucket for videos.
#
# Replication rule only for production.
#
resource "aws_s3_bucket" "originals_video" {
  bucket = "${local.name_prefix}-originals-video"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    "service"        = local.service_tag
    "use"            = "originals"
    "S3-Bucket-Name" = "${local.name_prefix}-originals-video"
  }

  # logging {
  #    target_bucket = "chf-logs"
  #    target_prefix = "s3_server_access_${terraform.workspace}_originals_video/"
  # }
}

resource "aws_s3_bucket_replication_configuration" "originals_video" {
  count  = terraform.workspace == "production" ? 1 : 0
  bucket = aws_s3_bucket.originals_video.id
  role   = aws_iam_role.S3-Backup-Replication[0].arn
  rule {
    id       = "Backup"
    priority = 0
    status   = "Enabled"
    destination {
      bucket = aws_s3_bucket.originals_video_backup[0].arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "originals_video" {
  bucket = aws_s3_bucket.originals_video.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "originals_video" {
  bucket = aws_s3_bucket.originals_video.id
  rule {
    status = "Enabled"
    id     = "Expire previous files"

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }

  rule {
    status = "Enabled"
    id     = "scihist-digicoll-${terraform.workspace}-originals-video-IT-Rule"

    transition {
      days          = 30
      storage_class = "INTELLIGENT_TIERING"
    }
  }
}

resource "aws_s3_bucket_versioning" "originals_video" {
  bucket = aws_s3_bucket.originals_video.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "originals_video" {
  bucket = aws_s3_bucket.originals_video.id

  rule {
    bucket_key_enabled = false
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}