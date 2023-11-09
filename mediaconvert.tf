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
          Resource = aws_iam_role.dev_mediaconvert_role.arn
          Sid      = "iamPassRole"
        },
      ]
      Version = "2012-10-17"
    }
  )
  tags     = {}
  tags_all = {}
}

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

# aws_iam_role.staging_mediaconvert_role:
resource "aws_iam_role" "staging_mediaconvert_role" {
  count = terraform.workspace == "staging" ? 1 : 0
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
  description           = "Allows MediaConvert service to call S3 APIs and API Gateway on your behalf. STAGING"
  force_detach_policies = false
  managed_policy_arns = [
    aws_iam_policy.bucket_access_from_app_staging[0].arn,
    "arn:aws:iam::aws:policy/AmazonAPIGatewayInvokeFullAccess",
  ]
  max_session_duration = 3600
  name                 = "scihist-digicoll-staging-MediaConvertRole"
  path                 = "/"
  tags                 = {}
  tags_all             = {}
}

# aws_iam_role.production_mediaconvert_role:
resource "aws_iam_role" "production_mediaconvert_role" {
  count = terraform.workspace == "production" ? 1 : 0
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
  description           = "Allows MediaConvert service to call S3 APIs and API Gateway on your behalf. PRODUCTION"
  force_detach_policies = false
  managed_policy_arns = [
    aws_iam_policy.bucket_access_from_app_production[0].arn,
    "arn:aws:iam::aws:policy/AmazonAPIGatewayInvokeFullAccess",
  ]
  max_session_duration = 3600
  name                 = "scihist-digicoll-production-MediaConvertRole"
  path                 = "/"
  tags                 = {}
  tags_all             = {}
}