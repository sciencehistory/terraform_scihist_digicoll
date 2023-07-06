resource "aws_s3_bucket" "derivatives" {
  bucket = "${local.name_prefix}-derivatives"

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
    "use"            = "derivatives"
    "S3-Bucket-Name" = "${local.name_prefix}-derivatives"
  }

  # only Enabled for production.
  dynamic "replication_configuration" {
    // hacky way to make this conditional, once and only once on production.
    for_each = terraform.workspace == "production" ? [1] : []
    content {
      # we're not controlling the IAM role with terraform, so we just hardcode it for now.
      role = "arn:aws:iam::335460257737:role/S3-Backup-Replication"

      rules {
        id       = "Backup"
        priority = 0
        status   = "Enabled"

        destination {
          bucket = one(aws_s3_bucket.derivatives_backup).arn
        }
      }
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
