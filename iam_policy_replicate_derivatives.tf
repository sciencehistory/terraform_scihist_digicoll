# aws_iam_policy.replicate_derivatives:
resource "aws_iam_policy" "replicate_derivatives" {
  count       = terraform.workspace == "production" ? 1 : 0
  description = "Cross-region replication for derivatives"
  name        = "replicate_derivatives"
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
          Effect   = "Allow"
          Resource = "${aws_s3_bucket.derivatives_backup[0].arn}/*"
        },
      ]
      Version = "2012-10-17"
    }
  )
  tags     = {}
  tags_all = {}
}