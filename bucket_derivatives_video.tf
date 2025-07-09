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
    "use"            = "derivatives-video"
    "S3-Bucket-Name" = "${local.name_prefix}-derivatives-video"
  }
}

resource "aws_s3_bucket_public_access_block" "derivatives_video" {
  bucket = aws_s3_bucket.originals.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "derivatives_video" {
  bucket = aws_s3_bucket.derivatives_video.id
  policy = templatefile("templates/s3_cloudfront_access_policy.tftpl",
    {
      bucket_name : aws_s3_bucket.derivatives_video.id,
      cloudfront_arn : aws_cloudfront_distribution.derivatives-video.arn
  })
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

    transition {
      days          = 30
      storage_class = "INTELLIGENT_TIERING"
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

# probably not really necessary now that we're fronting with
# cloudfront and having CF add CORS headers
resource "aws_s3_bucket_cors_configuration" "derivatives-video" {
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

# $ terraform import aws_s3_bucket_logging.originals_logging scihist-digicoll-staging-originals
resource "aws_s3_bucket_logging" "derivatives_video_logging" {
  bucket        = aws_s3_bucket.derivatives_video.id
  target_bucket = aws_s3_bucket.chf-logs.id
  target_prefix = "s3_access_logs/${terraform.workspace}-derivatives-video/"
}

# Video-derviatives cloudfront, in front of S3
# * cheaper price class North America/Europe only
# * add on cache-control header with far future caches for clients,
#   since MediaConvert won't write those in our outputs in S3 already
resource "aws_cloudfront_distribution" "derivatives-video" {
  comment         = "${terraform.workspace}-derivatives-video S3"
  enabled         = true
  is_ipv6_enabled = true

  # North America/Europe only, cheaper price class
  price_class = "PriceClass_100"

  origin {
    connection_attempts = 3
    connection_timeout  = 1
    domain_name         = "scihist-digicoll-${terraform.workspace}-derivatives-video.s3.${var.aws_region}.amazonaws.com"
    origin_id           = "${terraform.workspace}-derivatives-video.s3"

    # Sign requests so we can pass through response-content-disposition etc
    origin_access_control_id = aws_cloudfront_origin_access_control.signing-s3.id
  }

  # add tag matching bucket name tag used for S3 buckets themselves,
  # for cost analysis.
  tags = {
    "service"                           = local.service_tag
    "use"                               = "derivatives-video"
    "Cloudfront-Distribution-Origin-Id" = "${terraform.workspace}-derivatives-video.s3"
    "S3-Bucket-Name"                    = "${local.name_prefix}-derivatives-video"
  }


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

    # We're already sending mp4 content, adding gzip compression on top
    # won't help and may hurt.
    compress = false

    target_origin_id       = "${terraform.workspace}-derivatives-video.s3"
    viewer_protocol_policy = "https-only"

    cache_policy_id = data.aws_cloudfront_cache_policy.Managed-CachingOptimized.id

    # references policy for far-future Cache-Control header to be added
    response_headers_policy_id = aws_cloudfront_response_headers_policy.cors-with-preflight-and-long-time-cache.id
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

  logging_config {
    bucket          = aws_s3_bucket.chf-logs.bucket_domain_name
    include_cookies = false
    prefix          = "cloudfront_access_logs/${terraform.workspace}-derivatives-video/"
  }
}
