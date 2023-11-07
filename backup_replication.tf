# Replication:
# terraform import aws_iam_role.S3-Backup-Replication S3-Backup-Replication
# aws_iam_role.S3-Backup-Replication:
resource "aws_iam_role" "S3-Backup-Replication" {
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
    aws_iam_policy.replicate_derivatives.arn,
    aws_iam_policy.replicate_dzi.arn,
    aws_iam_policy.replicate_originals.arn,
    aws_iam_policy.replicate_originals_video.arn
  ]
  max_session_duration = 3600
  name                 = "S3-Backup-Replication"
  path                 = "/"
  tags                 = {}
  tags_all             = {}
}


#  terraform import aws_iam_policy.replicate_originals_video arn:aws:iam::335460257737:policy/replicate_originals_video
# aws_iam_policy.replicate_originals_video:
resource "aws_iam_policy" "replicate_originals_video" {
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
            "arn:aws:s3:::scihist-digicoll-production-originals-video",
            "arn:aws:s3:::scihist-digicoll-production-originals-video/*",
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
          Resource = "arn:aws:s3:::scihist-digicoll-production-originals-video-backup/*"
        },
      ]
      Version = "2012-10-17"
    }
  )
  tags     = {}
  tags_all = {}
}


# terraform import aws_iam_policy.replicate_originals arn:aws:iam::335460257737:policy/replicate_originals
# aws_iam_policy.replicate_originals:
resource "aws_iam_policy" "replicate_originals" {
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
            "arn:aws:s3:::scihist-digicoll-production-originals",
            "arn:aws:s3:::scihist-digicoll-production-originals/*",
            "arn:aws:s3:::scihist-digicoll-production-dzi",
            "arn:aws:s3:::scihist-digicoll-production-dzi/*",
            "arn:aws:s3:::scihist-digicoll-production-derivatives",
            "arn:aws:s3:::scihist-digicoll-production-derivatives/*",
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
            "arn:aws:s3:::scihist-digicoll-production-originals-backup/*",
            "arn:aws:s3:::scihist-digicoll-production-dzi-backup/*",
            "arn:aws:s3:::scihist-digicoll-production-derivatives-backup/*",
          ]
        },
      ]
      Version = "2012-10-17"
    }
  )
  tags     = {}
  tags_all = {}
}

# terraform import aws_iam_policy.replicate_dzi arn:aws:iam::335460257737:policy/replicate_dzi

# aws_iam_policy.replicate_dzi:
resource "aws_iam_policy" "replicate_dzi" {
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
            "arn:aws:s3:::scihist-digicoll-production-dzi",
            "arn:aws:s3:::scihist-digicoll-production-dzi/*",
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
          Resource = "arn:aws:s3:::scihist-digicoll-production-dzi-backup/*"
        },
      ]
      Version = "2012-10-17"
    }
  )
  tags     = {}
  tags_all = {}
}

# # terraform import aws_iam_policy.replicate_derivatives arn:aws:iam::335460257737:policy/replicate_derivatives
# aws_iam_policy.replicate_derivatives:
resource "aws_iam_policy" "replicate_derivatives" {
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
            "arn:aws:s3:::scihist-digicoll-production-derivatives",
            "arn:aws:s3:::scihist-digicoll-production-derivatives/*",
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
          Resource = "arn:aws:s3:::scihist-digicoll-production-derivatives-backup/*"
        },
      ]
      Version = "2012-10-17"
    }
  )
  tags     = {}
  tags_all = {}
}