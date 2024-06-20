# outputs, all-caps ones generally match heroku config var that should be set to value of output

output "RAILS_ASSET_HOST" {
  value = aws_cloudfront_distribution.rails_static_assets.domain_name
}

output "S3_BUCKET_DERIVATIVES_VIDEO_HOST" {
  value = aws_cloudfront_distribution.derivatives-video.domain_name
}

output "S3_BUCKET_DERIVATIVES_HOST" {
  value = aws_cloudfront_distribution.derivatives.domain_name
}

output "S3_BUCKET_ORIGINALS_HOST" {
  value = aws_cloudfront_distribution.originals.domain_name
}
