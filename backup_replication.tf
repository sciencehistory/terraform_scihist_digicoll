# aws_iam_role.S3-Backup-Replication:
resource "aws_iam_role" "S3-Backup-Replication" {
  count = terraform.workspace == "production" ? 1 : 0
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "s3.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  description           = "Replication role for backing up data between thumbnail bucket in US-EAST and backup bucket in US-WEST. Does not replicate delete commands, so breaks the normal cross-region replication rule there. Deletes must be done manually."
  force_detach_policies = false
  managed_policy_arns = [
    aws_iam_policy.replicate_derivatives[0].arn,
    aws_iam_policy.replicate_dzi[0].arn,
    aws_iam_policy.replicate_originals[0].arn,
    aws_iam_policy.replicate_originals_video[0].arn
  ]
  max_session_duration = 3600
  name                 = "S3-Backup-Replication"
  path                 = "/"
  tags                 = {}
  tags_all             = {}
}


# aws_iam_policy.replicate_originals_video:
resource "aws_iam_policy" "replicate_originals_video" {
  count       = terraform.workspace == "production" ? 1 : 0
  description = "Cross-region replication for originals_video"
  name        = "replicate_originals_video"
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
            "${aws_s3_bucket.originals_video.arn}",
            "${aws_s3_bucket.originals_video.arn}/*",
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
          Resource = "${aws_s3_bucket.originals_video_backup[0].arn}/*"
        },
      ]
      Version = "2012-10-17"
    }
  )
  tags     = {}
  tags_all = {}
}

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