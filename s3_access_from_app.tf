# These two policies govern access to S3
# from the production and staging apps, respectively.

# aws_iam_policy.bucket_access_from_app_production:
resource "aws_iam_policy" "bucket_access_from_app_production" {
  count       = terraform.workspace == "production" ? 1 : 0
  description = "Production access for scihist_digicoll application. Does not include backup access."
  name        = "S3_kithe_production"
  path        = "/"
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "s3:*",
          ]
          Effect = "Allow"
          Resource = [
            "${aws_s3_bucket.originals.arn}",
            "${aws_s3_bucket.originals.arn}/*",
            "${aws_s3_bucket.originals_video.arn}",
            "${aws_s3_bucket.originals_video.arn}/*",

            "${aws_s3_bucket.derivatives.arn}",
            "${aws_s3_bucket.derivatives.arn}/*",
            "${aws_s3_bucket.derivatives_video.arn}",
            "${aws_s3_bucket.derivatives_video.arn}/*",

            "${aws_s3_bucket.ondemand_derivatives.arn}",
            "${aws_s3_bucket.ondemand_derivatives.arn}/*",
            "${aws_s3_bucket.dzi.arn}",
            "${aws_s3_bucket.dzi.arn}/*",

            "${aws_s3_bucket.ingest_mount.arn}",
            "${aws_s3_bucket.ingest_mount.arn}/*",
            "${aws_s3_bucket.uploads.arn}",
            "${aws_s3_bucket.uploads.arn}/*",

            "${aws_s3_bucket.originals_backup[0].arn}",
            "${aws_s3_bucket.originals_backup[0].arn}/*",
            "${aws_s3_bucket.derivatives_backup[0].arn}",
            "${aws_s3_bucket.derivatives_backup[0].arn}/*",
            "${aws_s3_bucket.dzi_backup[0].arn}",
            "${aws_s3_bucket.dzi_backup[0].arn}/*",
          ]
          Sid = "Stmt1501524130000"
        },
      ]
      Version = "2012-10-17"
    }
  )
  tags     = {}
  tags_all = {}
}

# This is similar to the above, but without the
# backup buckets.

# aws_iam_policy.bucket_access_from_app_staging:
resource "aws_iam_policy" "bucket_access_from_app_staging" {
  count       = terraform.workspace == "staging" ? 1 : 0
  description = "Access to all Kithe buckets in S3 for staging"
  name        = "S3_kithe_staging"
  path        = "/"
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "s3:*",
          ]
          Effect = "Allow"
          Resource = [
            "${aws_s3_bucket.originals.arn}",
            "${aws_s3_bucket.originals.arn}/*",
            "${aws_s3_bucket.originals_video.arn}",
            "${aws_s3_bucket.originals_video.arn}/*",

            "${aws_s3_bucket.derivatives.arn}",
            "${aws_s3_bucket.derivatives.arn}/*",
            "${aws_s3_bucket.derivatives_video.arn}",
            "${aws_s3_bucket.derivatives_video.arn}/*",

            "${aws_s3_bucket.ondemand_derivatives.arn}",
            "${aws_s3_bucket.ondemand_derivatives.arn}/*",
            "${aws_s3_bucket.dzi.arn}",
            "${aws_s3_bucket.dzi.arn}/*",

            "${aws_s3_bucket.ingest_mount.arn}",
            "${aws_s3_bucket.ingest_mount.arn}/*",
            "${aws_s3_bucket.uploads.arn}",
            "${aws_s3_bucket.uploads.arn}/*",
          ]
          Sid = "Stmt1501524130000"
        },
      ]
      Version = "2012-10-17"
    }
  )
  tags     = {}
  tags_all = {}
}