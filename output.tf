# outputs, all-caps ones generally match heroku config var that should be set to value of output

output "RAILS_ASSET_HOST" {
  value = aws_cloudfront_distribution.rails_static_assets.domain_name
}

output "CLOUDFRONT_KEY_PAIR_ID" {
  value = aws_cloudfront_public_key.scihist-digicoll.id
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

output "S3_BUCKET_DZI_HOST" {
  value = aws_cloudfront_distribution.dzi.domain_name
}

output "S3_BUCKET_ON_DEMAND_DERIVATIVES_HOST" {
  value = aws_cloudfront_distribution.ondemand_derivatives.domain_name
}
