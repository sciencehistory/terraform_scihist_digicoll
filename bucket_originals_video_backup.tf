resource "aws_s3_bucket" "originals_video_backup" {
  count    = terraform.workspace == "production" ? 1 : 0
  provider = aws.backup

  bucket = "${local.name_prefix}-originals-video-backup"

  tags = {
    "service"        = "kithe"
    "use"            = "originals"
    "S3-Bucket-Name" = "${local.name_prefix}-originals-video-backup"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "originals_video_backup" {
  count  = terraform.workspace == "production" ? 1 : 0
  bucket = "${local.name_prefix}-originals-video-backup"

  rule {
    status = "Enabled"
    id     = "Expire previous files"

    expiration {
      days = 30
    }
  }

  rule {
    status = "Enabled"
    id     = "${local.name_prefix}-originals-video-backup_Lifecycle"

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }
  }
}

resource "aws_s3_bucket_versioning" "originals_video_backup" {
  count  = terraform.workspace == "production" ? 1 : 0
  bucket = aws_s3_bucket.originals_video_backup[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "originals_video_backup" {
  count  = terraform.workspace == "production" ? 1 : 0
  bucket = aws_s3_bucket.originals_video_backup[0].id
  rule {
    bucket_key_enabled = false
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
