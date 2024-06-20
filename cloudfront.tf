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
    domain_name = "scihist-digicoll-${terraform.workspace}-derivatives-video.s3.${var.aws_region}.amazonaws.com"
    origin_id   = "${terraform.workspace}-derivatives-video.s3"
  }

  # add tag matching bucket name tag used for S3 buckets themselves,
  # for cost analysis.
  tags = {
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

    # AWS Managed policy for `Managed-CachingOptimizedForUncompressedObjects`
    cache_policy_id = "b2884449-e4de-46a7-ac36-70bc7f1ddd6d"

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
    minimum_protocol_version       = "TLSv1"
  }
}

# Used by any CloudFronts in front of content at "immutable" URLs (random URL
# that will necessarily change if content does), but where origin (eg S3)
# is not providing far-future Cache headers -- we add them in.
resource "aws_cloudfront_response_headers_policy" "long-time-immutable-cache" {
  name    = "long-time-immutable-cache-${terraform.workspace}"
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
  name    = "cors-with-preflight-and-long-time-cache-${terraform.workspace}"
  comment = "far future Cache-Control"

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
