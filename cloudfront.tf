# cloudfront distro we use for caching static asset content, recommended by heroku

resource "aws_cloudfront_distribution" "rails_static_assets" {

    comment                        = "${terraform.workspace} static assets"
    enabled                        = true
    is_ipv6_enabled                = true

    default_cache_behavior {
        allowed_methods        = [
            "GET",
            "HEAD",
            "OPTIONS",
        ]
        cached_methods         = [
            "GET",
            "HEAD",
            "OPTIONS",
        ]

        target_origin_id       = "scihist-digicoll-${terraform.workspace}.herokuapp.com"
        viewer_protocol_policy = "https-only"

        forwarded_values {
          query_string = false
          cookies {
            forward = "none"
          }
        }
    }

    origin {
        domain_name         = "scihist-digicoll-${terraform.workspace}.herokuapp.com"
        origin_id           = "scihist-digicoll-${terraform.workspace}.herokuapp.com"

        custom_origin_config {
            http_port                = 80
            https_port               = 443
            origin_protocol_policy   = "https-only"
            origin_ssl_protocols     = [
                "TLSv1",
                "TLSv1.1",
                "TLSv1.2",
            ]
        }
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
