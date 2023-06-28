#
# A bucket just for our on-demand derivatives, serves as a kind of cache, has
# lifecycle rules to delete ones that haven't been accessed in a while.
#
# Doesn't need a public policy cause we just set public-read ACLs on individual objects.
resource "aws_s3_bucket" "ondemand_derivatives" {
  bucket = "${local.name_prefix}-ondemand-derivatives"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    "service"        = local.service_tag
    "use"            = "cache"
    "S3-Bucket-Name" = "${local.name_prefix}-ondemand-derivatives"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "ondemand_derivatives" {
  bucket = "${local.name_prefix}-ondemand-derivatives"

  rule {
    status = "Enabled"
    id     = "Expire files"

    expiration {
      days                         = 20
      expired_object_delete_marker = false
    }
  }

  rule {
    status = "Enabled"
    id     = "scihist-digicoll-${terraform.workspace}-ondemand-derivatives-IA-Rule"

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }
  }
}

resource "aws_s3_bucket_versioning" "ondemand_derivatives" {
  bucket = aws_s3_bucket.ondemand_derivatives.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ondemand_derivatives" {
  bucket = aws_s3_bucket.ondemand_derivatives.id

  rule {
    bucket_key_enabled = false
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}