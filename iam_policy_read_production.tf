
# Read-only access to production buckets
# aws_iam_policy.read_production:
resource "aws_iam_policy" "read_production" {
  description = "Allows the dev_users group read-only access to production."
  name        = "read_production"
  path        = "/"
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:GetObjectTagging",
            "s3:GetObjectVersionTagging",
            "s3:ListBucket",
            "s3:ListBucketVersions",
          ]
          Effect = "Allow"
          Resource = [
            "arn:aws:s3:::scihist-digicoll-production-derivatives",
            "arn:aws:s3:::scihist-digicoll-production-derivatives/*",
            "arn:aws:s3:::scihist-digicoll-production-dzi",
            "arn:aws:s3:::scihist-digicoll-production-dzi/*",
            "arn:aws:s3:::scihist-digicoll-production-ingest-mount",
            "arn:aws:s3:::scihist-digicoll-production-ingest-mount/*",
            "arn:aws:s3:::scihist-digicoll-production-ondemand-derivatives",
            "arn:aws:s3:::scihist-digicoll-production-ondemand-derivatives/*",
            "arn:aws:s3:::scihist-digicoll-production-originals",
            "arn:aws:s3:::scihist-digicoll-production-originals/*",
            "arn:aws:s3:::scihist-digicoll-production-originals-video",
            "arn:aws:s3:::scihist-digicoll-production-originals-video/*",
            "arn:aws:s3:::scihist-digicoll-production-derivatives-video",
            "arn:aws:s3:::scihist-digicoll-production-derivatives-video/*",
            "arn:aws:s3:::scihist-digicoll-production-uploads",
            "arn:aws:s3:::scihist-digicoll-production-uploads/*",
          ]
          Sid = "readproduction"
        },
      ]
      Version = "2012-10-17"
    }
  )
  tags = {
    "production" = ""
    "read"       = ""
  }
  tags_all = {
    "production" = ""
    "read"       = ""
  }
}