# aws_iam_policy.mediaconvert_dev:
resource "aws_iam_group" "dev_users" {
  name = "dev_users"
  path = "/"
}

# aws_iam_policy.mediaconvert_dev:
resource "aws_iam_group_membership" "dev_users_membership" {
  name = "dev_users_membership"

  users = [
    aws_iam_user.eddie_dev.name,
    aws_iam_user.jrochkind_dev.name
  ]

  group = aws_iam_group.dev_users.name
}

# aws_iam_policy.mediaconvert_dev:
resource "aws_iam_user" "eddie_dev" {
  name = "eddie_dev"
  path = "/"
  tags = {
    "description" = "The development version of schihist_digicoll_dev on eddie s laptop uses this to connect to the development AWS buckets."
  }
  tags_all = {
    "description" = "The development version of schihist_digicoll_dev on eddie s laptop uses this to connect to the development AWS buckets."
  }
}

# aws_iam_policy.mediaconvert_dev:
resource "aws_iam_user" "jrochkind_dev" {
  name     = "jrochkind_dev"
  path     = "/"
  tags     = {}
  tags_all = {}
}

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

# aws_iam_group_policy_attachment.dev_users_mediaconvert_dev:
resource "aws_iam_group_policy_attachment" "dev_users_mediaconvert_dev" {
  group      = aws_iam_group.dev_users.name
  policy_arn = aws_iam_policy.mediaconvert_dev.arn
}

# aws_iam_policy.read_backups:
resource "aws_iam_policy" "read_backups" {
  description = "Allows the dev_users group read-only access to backups."
  name        = "read_backups"
  path        = "/"
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:GetObjectTagging",
            "s3:GetObjectVersionTagging",
            "s3:ListBucket",
            "s3:ListBucketVersions",
          ]
          Effect = "Allow"
          Resource = [
            "arn:aws:s3:::chf-hydra-backup",
            "arn:aws:s3:::chf-hydra-backup/*",
            "arn:aws:s3:::scihist-digicoll-production-originals-backup",
            "arn:aws:s3:::scihist-digicoll-production-originals-backup/*",
            "arn:aws:s3:::scihist-digicoll-production-originals-video-backup",
            "arn:aws:s3:::scihist-digicoll-production-originals-video-backup/*",
            "arn:aws:s3:::scihist-digicoll-production-derivatives-backup",
            "arn:aws:s3:::scihist-digicoll-production-derivatives-backup/*",
            "arn:aws:s3:::scihist-digicoll-production-dzi-backup",
            "arn:aws:s3:::scihist-digicoll-production-dzi-backup/*",
          ]
          Sid = "readbackups"
        },
      ]
      Version = "2012-10-17"
    }
  )
  tags = {
    "backups" = ""
    "read"    = ""
  }
  tags_all = {
    "backups" = ""
    "read"    = ""
  }
}

# aws_iam_group_policy_attachment.dev_users_mediaconvert_dev:
resource "aws_iam_group_policy_attachment" "dev_users_read_backups" {
  group      = aws_iam_group.dev_users.name
  policy_arn = aws_iam_policy.read_backups.arn
}

# aws_iam_policy.read_production:
resource "aws_iam_policy" "read_production" {
  description = "Allows the dev_users group read-only access to production."
  name        = "read_production"
  path        = "/"
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:GetObjectTagging",
            "s3:GetObjectVersionTagging",
            "s3:ListBucket",
            "s3:ListBucketVersions",
          ]
          Effect = "Allow"
          Resource = [
            "arn:aws:s3:::scihist-digicoll-production-derivatives",
            "arn:aws:s3:::scihist-digicoll-production-derivatives/*",
            "arn:aws:s3:::scihist-digicoll-production-dzi",
            "arn:aws:s3:::scihist-digicoll-production-dzi/*",
            "arn:aws:s3:::scihist-digicoll-production-ingest-mount",
            "arn:aws:s3:::scihist-digicoll-production-ingest-mount/*",
            "arn:aws:s3:::scihist-digicoll-production-ondemand-derivatives",
            "arn:aws:s3:::scihist-digicoll-production-ondemand-derivatives/*",
            "arn:aws:s3:::scihist-digicoll-production-originals",
            "arn:aws:s3:::scihist-digicoll-production-originals/*",
            "arn:aws:s3:::scihist-digicoll-production-originals-video",
            "arn:aws:s3:::scihist-digicoll-production-originals-video/*",
            "arn:aws:s3:::scihist-digicoll-production-derivatives-video",
            "arn:aws:s3:::scihist-digicoll-production-derivatives-video/*",
            "arn:aws:s3:::scihist-digicoll-production-uploads",
            "arn:aws:s3:::scihist-digicoll-production-uploads/*",
          ]
          Sid = "readproduction"
        },
      ]
      Version = "2012-10-17"
    }
  )
  tags = {
    "production" = ""
    "read"       = ""
  }
  tags_all = {
    "production" = ""
    "read"       = ""
  }
}

# aws_iam_group_policy_attachment.dev_users_mediaconvert_dev:
resource "aws_iam_group_policy_attachment" "dev_users_read_production" {
  group      = aws_iam_group.dev_users.name
  policy_arn = aws_iam_policy.read_production.arn
}

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

# aws_iam_group_policy_attachment.dev_users_mediaconvert_dev:
resource "aws_iam_group_policy_attachment" "dev_users_write_dev" {
  group      = aws_iam_group.dev_users.name
  policy_arn = aws_iam_policy.write_dev.arn
}

# aws_iam_policy.write_staging:
resource "aws_iam_policy" "write_staging" {
  description = "Allows the dev_users group full access to staging."
  name        = "write_staging"
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
            "arn:aws:s3:::scihist-digicoll-staging-derivatives",
            "arn:aws:s3:::scihist-digicoll-staging-derivatives/*",
            "arn:aws:s3:::scihist-digicoll-staging-dzi",
            "arn:aws:s3:::scihist-digicoll-staging-dzi/*",
            "arn:aws:s3:::scihist-digicoll-staging-ingest-mount",
            "arn:aws:s3:::scihist-digicoll-staging-ingest-mount/*",
            "arn:aws:s3:::scihist-digicoll-staging-ondemand-derivatives",
            "arn:aws:s3:::scihist-digicoll-staging-ondemand-derivatives/*",
            "arn:aws:s3:::scihist-digicoll-staging-originals",
            "arn:aws:s3:::scihist-digicoll-staging-originals/*",
            "arn:aws:s3:::scihist-digicoll-staging-originals-video",
            "arn:aws:s3:::scihist-digicoll-staging-originals-video/*",
            "arn:aws:s3:::scihist-digicoll-staging-derivatives-video",
            "arn:aws:s3:::scihist-digicoll-staging-derivatives-video/*",
            "arn:aws:s3:::scihist-digicoll-staging-uploads",
            "arn:aws:s3:::scihist-digicoll-staging-uploads/*",
          ]
          Sid = "writestaging"
        },
      ]
      Version = "2012-10-17"
    }
  )
  tags = {
    "staging" = ""
    "write"   = ""
  }
  tags_all = {
    "staging" = ""
    "write"   = ""
  }
}

# aws_iam_group_policy_attachment.dev_users_mediaconvert_dev:
resource "aws_iam_group_policy_attachment" "dev_users_write_staging" {
  group      = aws_iam_group.dev_users.name
  policy_arn = aws_iam_policy.write_staging.arn
}

# aws_iam_policy.AmazonEC2ReadOnlyAccess:
resource "aws_iam_policy" "AmazonEC2ReadOnlyAccess" {
    description = "Provides read only access to Amazon EC2 via the AWS Management Console."
    name        = "AmazonEC2ReadOnlyAccess"
    path        = "/"
    policy      = jsonencode(
        {
            Statement = [
                {
                    Action   = "ec2:Describe*"
                    Effect   = "Allow"
                    Resource = "*"
                },
                {
                    Action   = "elasticloadbalancing:Describe*"
                    Effect   = "Allow"
                    Resource = "*"
                },
                {
                    Action   = [
                        "cloudwatch:ListMetrics",
                        "cloudwatch:GetMetricStatistics",
                        "cloudwatch:Describe*",
                    ]
                    Effect   = "Allow"
                    Resource = "*"
                },
                {
                    Action   = "autoscaling:Describe*"
                    Effect   = "Allow"
                    Resource = "*"
                },
            ]
            Version   = "2012-10-17"
        }
    )
    tags        = {}
    tags_all    = {}
}

# aws_iam_group_policy_attachment.dev_users_mediaconvert_dev:
resource "aws_iam_group_policy_attachment" "dev_users_AmazonEC2ReadOnlyAccess" {
  group      = aws_iam_group.dev_users.name
  policy_arn = aws_iam_policy.AmazonEC2ReadOnlyAccess.arn
}