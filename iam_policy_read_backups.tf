
# Read-only access to backup buckets
# aws_iam_policy.read_backups:
resource "aws_iam_policy" "read_backups" {
  description = "Allows the dev_users group read-only access to backups."
  name        = "read_backups"
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
            "arn:aws:s3:::chf-hydra-backup",
            "arn:aws:s3:::chf-hydra-backup/*",
            "arn:aws:s3:::scihist-digicoll-production-originals-backup",
            "arn:aws:s3:::scihist-digicoll-production-originals-backup/*",
            "arn:aws:s3:::scihist-digicoll-production-originals-video-backup",
            "arn:aws:s3:::scihist-digicoll-production-originals-video-backup/*",
            "arn:aws:s3:::scihist-digicoll-production-derivatives-backup",
            "arn:aws:s3:::scihist-digicoll-production-derivatives-backup/*",
            "arn:aws:s3:::scihist-digicoll-production-dzi-backup",
            "arn:aws:s3:::scihist-digicoll-production-dzi-backup/*",
          ]
          Sid = "readbackups"
        },
      ]
      Version = "2012-10-17"
    }
  )
  tags = {
    "backups" = ""
    "read"    = ""
  }
  tags_all = {
    "backups" = ""
    "read"    = ""
  }
}
