# Many of our s3 buckets have their own individual cloudfront distros on top; those are found
# in config files with the S3 buckets.
#
# Here are free-standing distros, and infrastructure used in common.

# cloudfront distro we use for caching static asset content, recommended by heroku
resource "aws_cloudfront_distribution" "rails_static_assets" {

  comment         = "${terraform.workspace} static assets"
  enabled         = true
  is_ipv6_enabled = true

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

    target_origin_id       = "scihist-digicoll-${terraform.workspace}.herokuapp.com"
    viewer_protocol_policy = "https-only"

    # AWS Managed-CachingOptimized policy
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }

  origin {
    domain_name = "scihist-digicoll-${terraform.workspace}.herokuapp.com"
    origin_id   = "scihist-digicoll-${terraform.workspace}.herokuapp.com"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols = [
        "TLSv1",
        "TLSv1.1",
        "TLSv1.2",
      ]
    }
  }

  tags = {
    "Cloudfront-Distribution-Origin-Id" = "scihist-digicoll-${terraform.workspace}.herokuapp.com"
  }

  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1"
  }
}

# An AWS OAC that we use for setting up CloudFront signed requests to S3, across
# several CF distributions and S3 buckets.
#
resource "aws_cloudfront_origin_access_control" "signing-s3" {
  description                       = "Cloudfront signed s3"
  name                              = "${local.name_prefix}-signing-s3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Cache policy which starts with common CachingOptimized, but also cache based on selected
# S3 query parameters. Including them in cache policy will make Cloudfront forward them to S3 too.
#
resource "aws_cloudfront_cache_policy"  "caching-optimized-plus-s3-params" {
  name        = "${local.name_prefix}-caching-optimized-plus-s3-params"
  comment     = "Based on Managed-CachingOptimized, but also including select S3 query params"
  default_ttl = 86400
  max_ttl     = 31536000
  min_ttl     = 1
  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true

    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "whitelist"
      query_strings {
        items = [
          "response-content-disposition",
          "response-content-type"
        ]
      }
    }
  }
}

# Import ID for AWS managed response and cache headers policy
#
data "aws_cloudfront_response_headers_policy" "Managed-CORS-with-preflight-and-SecurityHeadersPolicy" {
    name = "Managed-CORS-with-preflight-and-SecurityHeadersPolicy"
}

data "aws_cloudfront_response_headers_policy" "Managed-SecurityHeadersPolicy" {
    name = "Managed-SecurityHeadersPolicy"
}

data "aws_cloudfront_cache_policy" "Managed-CachingOptimized" {
    name = "Managed-CachingOptimized"
}


# Used by any CloudFronts in front of content at "immutable" URLs (random URL
# that will necessarily change if content does), but where origin (eg S3)
# is not providing far-future Cache headers -- we add them in.
resource "aws_cloudfront_response_headers_policy" "long-time-immutable-cache" {
  name    = "${terraform.workspace}-long-time-immutable-cache"
  comment = "far future Cache-Control"

  custom_headers_config {
    items {
      header   = "Cache-Control"
      override = false
      value    = "max-age=31536000, public, immutable"
    }
  }
}

# Taking:
# 1. force cache-control headers to far-future for immutable content, as above
#
# combined with
#
# 2. force "cors-with-preflight" headers, basing off the built-in managed policy
#   https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-response-headers-policies.html#managed-response-headers-policies-cors-preflight
#   This is meant to FORCE cors headers regardless of what source was providing --
#   we were having a heck of a time succesfully setting up and proxing from S3
#
# You can't use two policies at once, so we need to copy the managed one to add
# our thing onto it.
#
# Meant for use with video derivatives, which need CORS for video.js!
resource "aws_cloudfront_response_headers_policy" "cors-with-preflight-and-long-time-cache" {
  name    = "${terraform.workspace}-cors-with-preflight-and-long-time-cache"
  comment = "CORS preflight headers, with far future Cache-Control"

  custom_headers_config {
    items {
      header   = "Cache-Control"
      override = false
      value    = "max-age=31536000, public, immutable"
    }
  }

  cors_config {
    access_control_allow_credentials = false
    access_control_max_age_sec       = 43200
    origin_override                  = true

    access_control_allow_headers {
      items = [
        "*",
      ]
    }

    access_control_allow_methods {
      items = [
        "GET",
        "HEAD",
        "OPTIONS",
      ]
    }

    access_control_allow_origins {
      items = [
        "*",
      ]
    }

    access_control_expose_headers {
      items = [
        "*",
      ]
    }
  }

  security_headers_config {
  }
}

# private keys stored in 1password shared valut as `scihist-digicoll-staging_private_key.pem` and `scihist-digicoll-production-private_key.pem`
#  the private keys need to be exported from 1password in PKCS#8 format
resource "aws_cloudfront_public_key" "scihist-digicoll" {
  comment     = "public key used by our app for signing urls"
  encoded_key = file("./public_keys/${local.name_prefix}-public_key.pem")
  name        = "${local.name_prefix}-key-2024-1"
}

resource "aws_cloudfront_key_group" "scihist-digicoll" {
  comment = "key group used by our app for signing urls"
  items   = [aws_cloudfront_public_key.scihist-digicoll.id]
  name    = "${local.name_prefix}-group"
}

