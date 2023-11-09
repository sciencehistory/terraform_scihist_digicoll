# aws_iam_role.S3-Backup-Replication:
resource "aws_iam_role" "replication" {
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
