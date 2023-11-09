
# Full access to staging buckets
# aws_iam_policy.write_staging:
resource "aws_iam_policy" "write_staging" {
  description = "Allows the dev_users group full access to staging."
  name        = "write_staging"
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
            "arn:aws:s3:::scihist-digicoll-staging-derivatives",
            "arn:aws:s3:::scihist-digicoll-staging-derivatives/*",
            "arn:aws:s3:::scihist-digicoll-staging-dzi",
            "arn:aws:s3:::scihist-digicoll-staging-dzi/*",
            "arn:aws:s3:::scihist-digicoll-staging-ingest-mount",
            "arn:aws:s3:::scihist-digicoll-staging-ingest-mount/*",
            "arn:aws:s3:::scihist-digicoll-staging-ondemand-derivatives",
            "arn:aws:s3:::scihist-digicoll-staging-ondemand-derivatives/*",
            "arn:aws:s3:::scihist-digicoll-staging-originals",
            "arn:aws:s3:::scihist-digicoll-staging-originals/*",
            "arn:aws:s3:::scihist-digicoll-staging-originals-video",
            "arn:aws:s3:::scihist-digicoll-staging-originals-video/*",
            "arn:aws:s3:::scihist-digicoll-staging-derivatives-video",
            "arn:aws:s3:::scihist-digicoll-staging-derivatives-video/*",
            "arn:aws:s3:::scihist-digicoll-staging-uploads",
            "arn:aws:s3:::scihist-digicoll-staging-uploads/*",
          ]
          Sid = "writestaging"
        },
      ]
      Version = "2012-10-17"
    }
  )
  tags = {
    "staging" = ""
    "write"   = ""
  }
  tags_all = {
    "staging" = ""
    "write"   = ""
  }
}