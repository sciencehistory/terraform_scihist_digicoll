# aws_iam_role.scihist-digicoll-DEV-MediaConvertRole:
resource "aws_iam_role" "scihist-digicoll-DEV-MediaConvertRole" {
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

# aws_iam_role.scihist-digicoll-staging-MediaConvertRole:
resource "aws_iam_role" "scihist-digicoll-staging-MediaConvertRole" {
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
    "arn:aws:iam::335460257737:policy/S3_kithe_staging",
    "arn:aws:iam::aws:policy/AmazonAPIGatewayInvokeFullAccess",
  ]
  max_session_duration = 3600
  name                 = "scihist-digicoll-staging-MediaConvertRole"
  path                 = "/"
  tags                 = {}
  tags_all             = {}
}

# aws_iam_role.scihist-digicoll-production-MediaConvertRole:
resource "aws_iam_role" "scihist-digicoll-production-MediaConvertRole" {
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
    "arn:aws:iam::335460257737:policy/S3_kithe_production",
    "arn:aws:iam::aws:policy/AmazonAPIGatewayInvokeFullAccess",
  ]
  max_session_duration = 3600
  name                 = "scihist-digicoll-production-MediaConvertRole"
  path                 = "/"
  tags                 = {}
  tags_all             = {}
}