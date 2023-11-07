# terraform import aws_iam_policy.S3_kithe_production arn:aws:iam::335460257737:policy/S3_kithe_production
# aws_iam_policy.S3_kithe_production:
resource "aws_iam_policy" "S3_kithe_production" {
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

            "${aws_s3_bucket.derivatives_backup[0].arn}",
            "${aws_s3_bucket.derivatives_backup[0].arn}/*",
            "${aws_s3_bucket.dzi_backup[0].arn}",
            "${aws_s3_bucket.dzi_backup[0].arn}/*",
            "${aws_s3_bucket.originals_backup[0].arn}",
            "${aws_s3_bucket.originals_backup[0].arn}/*",
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