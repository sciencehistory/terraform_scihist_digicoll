
# aws_iam_policy.replicate_originals_video:
resource "aws_iam_policy" "replicate_originals_video" {
  count       = terraform.workspace == "production" ? 1 : 0
  description = "Cross-region replication for originals_video"
  name        = "replicate_originals_video"
  path        = "/"
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "s3:Get*",
            "s3:ListBucket",
          ]
          Effect = "Allow"
          Resource = [
            "${aws_s3_bucket.originals_video.arn}",
            "${aws_s3_bucket.originals_video.arn}/*",
          ]
        },
        {
          Action = [
            "s3:ReplicateObject",
            "s3:ReplicateDelete",
            "s3:ReplicateTags",
            "s3:GetObjectVersionTagging",
          ]
          Effect   = "Allow"
          Resource = "${aws_s3_bucket.originals_video_backup[0].arn}/*"
        },
      ]
      Version = "2012-10-17"
    }
  )
  tags     = {}
  tags_all = {}
}
