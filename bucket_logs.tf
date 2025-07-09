# This bucket is shared by both production and staging at present....

# this terraform config is not right in that both staging and prod terraform workspaces currently think
# they control this same bucket. Should prob fix, but it's worked up to now and am not fixing right now.

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

# in s3_access_logs/ and cloudfront_access_logs/ prefixes, delete objects after 13 months
resource "aws_s3_bucket_lifecycle_configuration" "chf_logs" {
  bucket = "chf-logs"

  rule {
    id     = "expire_s3_access_logs"
    status = "Enabled"

    filter {
      prefix = "s3_access_logs/"
    }

    expiration {
      days                         = 395
      expired_object_delete_marker = false
    }
    noncurrent_version_expiration {
      noncurrent_days = 395
    }
  }

  rule {
    id     = "expire_cloudfront_access_logs"
    status = "Enabled"

    filter {
      prefix = "cloudfront_access_logs/"
    }

    expiration {
      days                         = 395
      expired_object_delete_marker = false
    }
    noncurrent_version_expiration {
      noncurrent_days = 395
    }
  }
}
