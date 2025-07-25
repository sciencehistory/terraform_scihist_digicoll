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
  bucket = aws_s3_bucket.ondemand_derivatives.id

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

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}

resource "aws_s3_bucket_policy" "ondemand_derivatives" {
  bucket = aws_s3_bucket.ondemand_derivatives.id
  policy = templatefile("templates/s3_cloudfront_access_policy.tftpl",
    {
      bucket_name : aws_s3_bucket.ondemand_derivatives.id,
      cloudfront_arn : aws_cloudfront_distribution.ondemand_derivatives.arn
  })
}

resource "aws_s3_bucket_public_access_block" "ondemand_derivatives" {
  bucket = aws_s3_bucket.ondemand_derivatives.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_cloudfront_distribution" "ondemand_derivatives" {
  comment         = "${terraform.workspace}-ondemand-derivatives S3"
  enabled         = true
  is_ipv6_enabled = true
  http_version    = "http2and3"

  # Only North America/Europe to save money
  price_class = "PriceClass_100"

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

    target_origin_id       = aws_s3_bucket.ondemand_derivatives.bucket_regional_domain_name
    viewer_protocol_policy = "https-only"

    cache_policy_id = aws_cloudfront_cache_policy.caching-optimized-plus-s3-params.id

    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.Managed-CORS-with-preflight-and-SecurityHeadersPolicy.id
  }

  origin {
    connection_attempts = 3
    connection_timeout  = 1
    domain_name         = aws_s3_bucket.ondemand_derivatives.bucket_regional_domain_name
    origin_id           = aws_s3_bucket.ondemand_derivatives.bucket_regional_domain_name

    # Sign requests for access to non-public bucket
    origin_access_control_id = aws_cloudfront_origin_access_control.signing-s3.id
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
    "service"                           = local.service_tag
    "use"                               = "ondemand-derivatives"
    "S3-Bucket-Name"                    = "${local.name_prefix}-ondemand-derivatives"
    "Cloudfront-Distribution-Origin-Id" = "${terraform.workspace}-ondemand-derivatives.s3"
  }

  logging_config {
    bucket          = aws_s3_bucket.chf-logs.bucket_domain_name
    include_cookies = false
    prefix          = "cloudfront_access_logs/${terraform.workspace}-ondemand-derivatives/"
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

# $ terraform import aws_s3_bucket_logging.originals_logging scihist-digicoll-staging-originals
resource "aws_s3_bucket_logging" "ondemand_derivatives" {
  bucket        = aws_s3_bucket.ondemand_derivatives.id
  target_bucket = aws_s3_bucket.chf-logs.id
  target_prefix = "s3_access_logs/${terraform.workspace}-ondemand-derivatives/"
}
