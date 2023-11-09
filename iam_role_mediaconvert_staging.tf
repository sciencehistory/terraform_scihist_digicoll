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

