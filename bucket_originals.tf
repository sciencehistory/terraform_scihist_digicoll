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

# Cloudfront distro fronting originals is RESTRICTED and needs signed urls,
#
# And it passes on response-content-disposition and response-content-type
#
resource "aws_cloudfront_distribution" "originals" {
  comment         = "${terraform.workspace}-originals S3"
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

    target_origin_id       = aws_s3_bucket.originals.bucket_regional_domain_name
    viewer_protocol_policy = "https-only"

    trusted_key_groups = [aws_cloudfront_key_group.scihist-digicoll.id]

    cache_policy_id = aws_cloudfront_cache_policy.caching-optimized-plus-s3-params.id

    # Don't need CORS on originals at present, but I guess security is good?
    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.Managed-SecurityHeadersPolicy.id
  }

  origin {
    connection_attempts       = 3
    connection_timeout        = 1
    domain_name               = aws_s3_bucket.originals.bucket_regional_domain_name
    origin_id                 = aws_s3_bucket.originals.bucket_regional_domain_name
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

  tags = {
    "service"        = local.service_tag
    "use"            = "originals"
    "S3-Bucket-Name" = "${local.name_prefix}-originals"
    "Cloudfront-Distribution-Origin-Id" = "${terraform.workspace}-originals.s3"
  }
}

resource "aws_s3_bucket_policy" "originals" {
  bucket = aws_s3_bucket.originals.id
  policy = templatefile("templates/s3_cloudfront_access_policy.tftpl",
                        {
                          bucket_name : aws_s3_bucket.originals.id,
                          cloudfront_arn : aws_cloudfront_distribution.originals.arn
                        })
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

# We may want to put this aws_s3_bucket in a separate file; would be more consistent with the existing setup.
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
# resource "aws_s3_bucket_logging" "originals_logging" {
#   bucket        = aws_s3_bucket.originals.id
#   target_bucket = aws_s3_bucket.chf-logs.id
#   target_prefix = "s3_server_access_${terraform.workspace}_originals/"
# }
