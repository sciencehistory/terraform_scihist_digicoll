#
# DZI tiles, in a public bucket. They are voluminous
#
# Replication only in production.
resource "aws_s3_bucket" "dzi" {
  bucket = "${local.name_prefix}-dzi"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    "service"        = local.service_tag
    "use"            = "dzi"
    "S3-Bucket-Name" = "${local.name_prefix}-dzi"
  }
}

resource "aws_s3_bucket_replication_configuration" "dzi" {
  count  = terraform.workspace == "production" ? 1 : 0
  bucket = aws_s3_bucket.dzi.id
  role   = aws_iam_role.replication[0].arn
  rule {
    id       = "Backup"
    priority = 0
    status   = "Enabled"
    destination {
      bucket = aws_s3_bucket.dzi_backup[0].arn
    }
  }
}

resource "aws_s3_bucket_policy" "dzi" {
  bucket = aws_s3_bucket.dzi.id
  policy = templatefile("templates/s3_cloudfront_access_policy.tftpl",
                        {
                          bucket_name : aws_s3_bucket.dzi.id,
                          cloudfront_arn : aws_cloudfront_distribution.dzi.arn
                        })

}

resource "aws_s3_bucket_public_access_block" "dzi" {
  bucket = aws_s3_bucket.dzi.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_distribution" "dzi" {
  comment         = "${local.name_prefix}-dzi bucket"
  enabled         = true
  is_ipv6_enabled = true
  http_version    = "http2and3"

  # Only North America/Europe to save money
  price_class     = "PriceClass_100"

  default_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
      "OPTIONS",
    ]
    cached_methods = [
      "GET",
      "HEAD",
      "OPTIONS",
    ]

    compress = true

    target_origin_id       = aws_s3_bucket.dzi.bucket_regional_domain_name
    viewer_protocol_policy = "https-only"

    # pass through response-content-disposition etc
    cache_policy_id = data.aws_cloudfront_cache_policy.Managed-CachingOptimized.id

    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.Managed-CORS-with-preflight-and-SecurityHeadersPolicy.id
  }

  origin {
    connection_attempts       = 3
    connection_timeout        = 1
    domain_name               = aws_s3_bucket.dzi.bucket_regional_domain_name
    origin_id                 = aws_s3_bucket.dzi.bucket_regional_domain_name

    # Sign requests to non-public bucket
    origin_access_control_id  = aws_cloudfront_origin_access_control.signing-s3.id
  }

  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  # Tag same as bucket origin to aggregate costs together
  tags = {
    "service"        = local.service_tag
    "use"            = "dzi"
    "S3-Bucket-Name" = "${local.name_prefix}-dzi"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "dzi" {
  bucket = aws_s3_bucket.dzi.id

  rule {
    status = "Enabled"
    id     = "Expire previous files"

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }

  rule {
    status = "Enabled"
    id     = "scihist-digicoll-${terraform.workspace}-dzi-IT-Rule"

    transition {
      days          = 30
      storage_class = "INTELLIGENT_TIERING"
    }
  }
}

resource "aws_s3_bucket_versioning" "dzi" {
  bucket = aws_s3_bucket.dzi.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "dzi" {
  bucket = aws_s3_bucket.dzi.id

  rule {
    bucket_key_enabled = false
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
