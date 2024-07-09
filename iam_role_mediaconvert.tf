# aws_iam_role.staging_mediaconvert_role:
resource "aws_iam_role" "mediaconvert_role" {
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "mediaconvert.amazonaws.com"
          }
          Sid = ""
        },
      ]
      Version = "2012-10-17"
    }
  )
  description           = "Allows MediaConvert service to call S3 APIs and API Gateway on your behalf -- ${terraform.workspace}"
  force_detach_policies = false
  managed_policy_arns = [
    aws_iam_policy.mediaconvert_role.arn,
    "arn:aws:iam::aws:policy/AmazonAPIGatewayInvokeFullAccess",
  ]
  max_session_duration = 3600
  name                 = "${local.name_prefix}-MediaConvertRole"
  path                 = "/"
  tags                 = {}
  tags_all             = {}
}


resource "aws_iam_policy" "mediaconvert_role" {
  description = "Access to S3 buckets necessary for our mediaconvert tasks -- ${terraform.workspace}"
  # name is legacy historical unfortunate for now
  name        = "${local.name_prefix}-MediaConvertRole"
  path        = "/"

  # Read access to originals, and read/write to any place we might want to store derivatives
  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Action = [
            "s3:Get*",
            "s3:List*"
          ],
          Effect = "Allow"
          Resource = [
            "${aws_s3_bucket.originals.arn}",
            "${aws_s3_bucket.originals.arn}/*",

            "${aws_s3_bucket.originals_video.arn}",
            "${aws_s3_bucket.originals_video.arn}/*"
          ]
        },
        {
          Action = [
            "s3:Get*",
            "s3:List*",
            "s3:Put*"
          ],
          Effect = "Allow"
          Resource = [
            "${aws_s3_bucket.derivatives.arn}",
            "${aws_s3_bucket.derivatives.arn}/*",

            "${aws_s3_bucket.derivatives_video.arn}",
            "${aws_s3_bucket.derivatives_video.arn}/*",

            "${aws_s3_bucket.ondemand_derivatives.arn}",
            "${aws_s3_bucket.ondemand_derivatives.arn}/*",
          ]
        },
      ]
    }
  )
  tags     = {}
  tags_all = {}
}
