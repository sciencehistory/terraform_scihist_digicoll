
# aws_iam_policy.replicate_dzi:
resource "aws_iam_policy" "replicate_dzi" {
  count       = terraform.workspace == "production" ? 1 : 0
  description = "Cross-region replication for dzi"
  name        = "replicate_dzi"
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
            aws_s3_bucket.dzi.arn,
            "${aws_s3_bucket.dzi.arn}/*",
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
          Resource = "${aws_s3_bucket.dzi_backup[0].arn}/*"
        },
      ]
      Version = "2012-10-17"
    }
  )
  tags     = {}
  tags_all = {}
}

