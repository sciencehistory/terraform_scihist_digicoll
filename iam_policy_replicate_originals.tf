
# aws_iam_policy.replicate_originals:
resource "aws_iam_policy" "replicate_originals" {
  count       = terraform.workspace == "production" ? 1 : 0
  description = "Cross-region replication for originals"
  name        = "replicate_originals"
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
            "${aws_s3_bucket.originals.arn}",
            "${aws_s3_bucket.originals.arn}/*",
            "${aws_s3_bucket.dzi.arn}",
            "${aws_s3_bucket.dzi.arn}/*",
            "${aws_s3_bucket.derivatives.arn}",
            "${aws_s3_bucket.derivatives.arn}/*",
          ]
        },
        {
          Action = [
            "s3:ReplicateObject",
            "s3:ReplicateDelete",
            "s3:ReplicateTags",
            "s3:GetObjectVersionTagging",
          ]
          Effect = "Allow"
          Resource = [
            "${aws_s3_bucket.originals_backup[0].arn}/*",
            "${aws_s3_bucket.dzi_backup[0].arn}/*",
            "${aws_s3_bucket.derivatives_backup[0].arn}/*",
          ]
        },
      ]
      Version = "2012-10-17"
    }
  )
  tags     = {}
  tags_all = {}
}
