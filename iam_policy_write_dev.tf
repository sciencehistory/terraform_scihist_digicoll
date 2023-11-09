# Full access to development buckets
# aws_iam_policy.write_dev:
resource "aws_iam_policy" "write_dev" {
  description = "Allows the dev_users group full access to dev."
  name        = "write_dev"
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
            "arn:aws:s3:::scih-data-dev",
            "arn:aws:s3:::scih-data-dev/*",
            "arn:aws:s3:::scih-uploads-dev",
            "arn:aws:s3:::scih-uploads-dev/*",
          ]
          Sid = "writedev"
        },
      ]
      Version = "2012-10-17"
    }
  )
  tags = {
    "dev"   = ""
    "write" = ""
  }
  tags_all = {
    "dev"   = ""
    "write" = ""
  }
}
