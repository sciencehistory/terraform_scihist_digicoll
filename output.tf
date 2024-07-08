# outputs, all-caps ones generally match heroku config var that should be set to value of output

output "S3_BUCKET_DERIVATIVES" {
  value = aws_s3_bucket.derivatives.bucket
}

output "S3_BUCKET_DERIVATIVES_VIDEO" {
  value = aws_s3_bucket.derivatives_video.bucket
}

output "S3_BUCKET_ON_DEMAND_DERIVATIVES" {
  value = aws_s3_bucket.ondemand_derivatives.bucket
}

output "S3_BUCKET_ORIGINALS" {
  value = aws_s3_bucket.originals.bucket
}

output "S3_BUCKET_ORIGINALS_VIDEO" {
  value = aws_s3_bucket.originals_video.bucket
}

output "S3_BUCKET_UPLOADS" {
  value = aws_s3_bucket.uploads.bucket
}

output "S3_BUCKET_DZI" {
  value = aws_s3_bucket.dzi.bucket
}


output "RAILS_ASSET_HOST" {
  value = aws_cloudfront_distribution.rails_static_assets.domain_name
}

output "S3_BUCKET_DERIVATIVES_VIDEO_HOST" {
  value = aws_cloudfront_distribution.derivatives-video.domain_name
}
