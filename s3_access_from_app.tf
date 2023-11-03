

# terraform import aws_iam_policy.S3_kithe_production arn:aws:iam::335460257737:policy/S3_kithe_production
# aws_iam_policy.S3_kithe_production:
resource "aws_iam_policy" "S3_kithe_production" {
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
            "arn:aws:s3:::scihist-digicoll-production-originals",
            "arn:aws:s3:::scihist-digicoll-production-originals/*",
            "arn:aws:s3:::scihist-digicoll-production-originals-video",
            "arn:aws:s3:::scihist-digicoll-production-originals-video/*",
            "arn:aws:s3:::scihist-digicoll-production-originals-backup",
            "arn:aws:s3:::scihist-digicoll-production-originals-backup/*",
            "arn:aws:s3:::scihist-digicoll-production-derivatives-video",
            "arn:aws:s3:::scihist-digicoll-production-derivatives-video/*",
            "arn:aws:s3:::scihist-digicoll-production-derivatives",
            "arn:aws:s3:::scihist-digicoll-production-derivatives/*",
            "arn:aws:s3:::scihist-digicoll-production-derivatives-backup",
            "arn:aws:s3:::scihist-digicoll-production-derivatives-backup/*",
            "arn:aws:s3:::scihist-digicoll-production-dzi",
            "arn:aws:s3:::scihist-digicoll-production-dzi/*",
            "arn:aws:s3:::scihist-digicoll-production-dzi-backup",
            "arn:aws:s3:::scihist-digicoll-production-dzi-backup/*",
            "arn:aws:s3:::scihist-digicoll-production-uploads",
            "arn:aws:s3:::scihist-digicoll-production-uploads/*",
            "arn:aws:s3:::scihist-digicoll-production-ingest-mount",
            "arn:aws:s3:::scihist-digicoll-production-ingest-mount/*",
            "arn:aws:s3:::scihist-digicoll-production-ondemand-derivatives",
            "arn:aws:s3:::scihist-digicoll-production-ondemand-derivatives/*",
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

# terraform import aws_iam_policy.S3_kithe_staging arn:aws:iam::335460257737:policy/S3_kithe_staging
# aws_iam_policy.S3_kithe_staging:
resource "aws_iam_policy" "S3_kithe_staging" {
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
            "arn:aws:s3:::scihi-kithe-stage-originals",
            "arn:aws:s3:::scihi-kithe-stage-originals/*",
            "arn:aws:s3:::scihi-kithe-stage-derivatives",
            "arn:aws:s3:::scihi-kithe-stage-derivatives/*",
            "arn:aws:s3:::scihi-kithe-stage-dzi",
            "arn:aws:s3:::scihi-kithe-stage-dzi/*",
            "arn:aws:s3:::scihi-kithe-stage-originals-backup",
            "arn:aws:s3:::scihi-kithe-stage-originals-backup/*",
            "arn:aws:s3:::scihi-kithe-stage-derivatives-backup",
            "arn:aws:s3:::scihi-kithe-stage-derivatives-backup/*",
            "arn:aws:s3:::scihi-kithe-stage-dzi-backup",
            "arn:aws:s3:::scihi-kithe-stage-dzi-backup/*",
            "arn:aws:s3:::scihi-kithe-stage-uploads",
            "arn:aws:s3:::scihi-kithe-stage-uploads/*",
            "arn:aws:s3:::scihi-kithe-stage-files",
            "arn:aws:s3:::scihi-kithe-stage-files/*",
            "arn:aws:s3:::scihi-kithe-stage-ondemand-derivatives",
            "arn:aws:s3:::scihi-kithe-stage-ondemand-derivatives/*",
            "arn:aws:s3:::scih-uploads",
            "arn:aws:s3:::scih-uploads/*",
            "arn:aws:s3:::scihist-digicoll-staging-originals",
            "arn:aws:s3:::scihist-digicoll-staging-originals/*",
            "arn:aws:s3:::scihist-digicoll-staging-originals-video",
            "arn:aws:s3:::scihist-digicoll-staging-originals-video/*",
            "arn:aws:s3:::scihist-digicoll-staging-derivatives-video",
            "arn:aws:s3:::scihist-digicoll-staging-derivatives-video/*",
            "arn:aws:s3:::scihist-digicoll-staging-derivatives",
            "arn:aws:s3:::scihist-digicoll-staging-derivatives/*",
            "arn:aws:s3:::scihist-digicoll-staging-dzi",
            "arn:aws:s3:::scihist-digicoll-staging-dzi/*",
            "arn:aws:s3:::scihist-digicoll-staging-uploads",
            "arn:aws:s3:::scihist-digicoll-staging-uploads/*",
            "arn:aws:s3:::scihist-digicoll-staging-ingest-mount",
            "arn:aws:s3:::scihist-digicoll-staging-ingest-mount/*",
            "arn:aws:s3:::scihist-digicoll-staging-ondemand-derivatives",
            "arn:aws:s3:::scihist-digicoll-staging-ondemand-derivatives/*",
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