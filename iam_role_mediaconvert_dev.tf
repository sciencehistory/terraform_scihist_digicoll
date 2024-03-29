
# aws_iam_role.dev_mediaconvert_role:
resource "aws_iam_role" "dev_mediaconvert_role" {
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
  description           = "Allows MediaConvert service to call S3 APIs and API Gateway on your behalf."
  force_detach_policies = false
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonAPIGatewayInvokeFullAccess",
  ]
  max_session_duration = 3600
  name                 = "scihist-digicoll-DEV-MediaConvertRole"
  path                 = "/"
  tags                 = {}
  tags_all             = {}

  inline_policy {
    name = "S3-scih-data-dev"
    policy = jsonencode(
      {
        Statement = [
          {
            Action = [
              "s3:*",
              "s3-object-lambda:*",
            ]
            Effect = "Allow"
            Resource = [
              "arn:aws:s3:::scih-data-dev",
              "arn:aws:s3:::scih-data-dev/*",
            ]
          },
        ]
        Version = "2012-10-17"
      }
    )
  }
}

