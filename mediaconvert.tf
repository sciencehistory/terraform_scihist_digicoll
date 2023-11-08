# These roles and policies allow the Mediaconvert service
# (which we use to make derivatives for video files)
# to call s3 services on your behalf,
# in dev, staging and production respectively.


# aws_iam_policy.mediaconvert_dev:
resource "aws_iam_policy" "mediaconvert_dev" {
  description = "Ability to start mediaconvert jobs, with dev mediaconvert role"
  name        = "mediaconvert_dev"
  path        = "/"
  policy = jsonencode(
    {
      Statement = [
        {
          Action   = "mediaconvert:*"
          Effect   = "Allow"
          Resource = "*"
          Sid      = "mediaconvertActions"
        },
        {
          Action   = "iam:PassRole"
          Effect   = "Allow"
          Resource = "arn:aws:iam::335460257737:role/scihist-digicoll-DEV-MediaConvertRole"
          Sid      = "iamPassRole"
        },
      ]
      Version = "2012-10-17"
    }
  )
  tags     = {}
  tags_all = {}
}
