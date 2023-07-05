#
# Original assets, as ingested, in a private bucket
#
# Replication rule only for production.
#
resource "aws_s3_bucket" "originals" {
  bucket = "${local.name_prefix}-originals"

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
    "use"            = "originals"
    "S3-Bucket-Name" = "${local.name_prefix}-originals"
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
          bucket = one(aws_s3_bucket.originals_backup).arn
        }
      }
    }
  }

  # logging {
  #    target_bucket = "chf-logs"
  #    target_prefix = "s3_server_access_${terraform.workspace}_originals/"
  # }
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

    expiration {
      days = 30
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
