# outputs, all-caps ones generally match heroku config var that should be set to value of output

output "AWS_MEDIACONVERT_ROLE_ARN" {
  value = aws_iam_role.mediaconvert_role.arn
}

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
