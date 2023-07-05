# Video derivatives, expected to be mainly/only HLS. Set up in a separate bucket from
# other videos for easier cost tracking. Also the method of creation/management differs.
#
# Set up to mimic the derivatives bucket.
#
# * EXCEPT: We've decided NOT to replicate to a backup bucket.
# * NOTE: This is intentionally set to publically readable -- like our other
#   derivatives bucket. In this case, signed URLs wouldn't work for HLS files,
#   as the manifest files have references to static urls in them too.
resource "aws_s3_bucket" "derivatives_video" {
  bucket = "${local.name_prefix}-derivatives-video"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    "service"        = local.service_tag
    "use"            = "derivatives"
    "S3-Bucket-Name" = "${local.name_prefix}-derivatives-video"
  }
}

resource "aws_s3_bucket_cors_configuration" "derivatives_video" {

  bucket = aws_s3_bucket.derivatives_video.id

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

resource "aws_s3_bucket_policy" "derivatives-video" {
  bucket = aws_s3_bucket.derivatives_video.id
  policy = templatefile("templates/s3_public_read_policy.tftpl", { bucket_name : aws_s3_bucket.derivatives_video.id })
}

resource "aws_s3_bucket_lifecycle_configuration" "derivatives_video" {
  bucket = aws_s3_bucket.derivatives_video.id

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

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "INTELLIGENT_TIERING"
    }
  }
}

resource "aws_s3_bucket_versioning" "derivatives_video" {
  bucket = aws_s3_bucket.derivatives_video.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "derivatives_video" {
  bucket = aws_s3_bucket.derivatives_video.id

  rule {
    bucket_key_enabled = false
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
