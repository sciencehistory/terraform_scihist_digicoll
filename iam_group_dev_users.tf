# This user group provides the development version of the app access to the AWS services it needs, and nothing else:
# aws_iam_group.dev_users:
resource "aws_iam_group" "dev_users" {
  name = "dev_users"
  path = "/"
}

# One user for each developer:
# aws_iam_group_membership.dev_users_membership:
resource "aws_iam_group_membership" "dev_users_membership" {
  name = "dev_users_membership"

  users = [
    aws_iam_user.eddie_dev.name,
    aws_iam_user.jrochkind_dev.name
  ]

  group = aws_iam_group.dev_users.name
}


# aws_iam_group_policy_attachment.dev_users_mediaconvert_dev:
resource "aws_iam_group_policy_attachment" "dev_users_mediaconvert_dev" {
  group      = aws_iam_group.dev_users.name
  policy_arn = aws_iam_policy.mediaconvert_dev.arn
}

# aws_iam_group_policy_attachment.dev_users_read_backups:
resource "aws_iam_group_policy_attachment" "dev_users_read_backups" {
  group      = aws_iam_group.dev_users.name
  policy_arn = aws_iam_policy.read_backups.arn
}


# aws_iam_group_policy_attachment.dev_users_read_production:
resource "aws_iam_group_policy_attachment" "dev_users_read_production" {
  group      = aws_iam_group.dev_users.name
  policy_arn = aws_iam_policy.read_production.arn
}


# aws_iam_group_policy_attachment.dev_users_write_dev:
resource "aws_iam_group_policy_attachment" "dev_users_write_dev" {
  group      = aws_iam_group.dev_users.name
  policy_arn = aws_iam_policy.write_dev.arn
}


# aws_iam_group_policy_attachment.dev_users_write_staging:
resource "aws_iam_group_policy_attachment" "dev_users_write_staging" {
  group      = aws_iam_group.dev_users.name
  policy_arn = aws_iam_policy.write_staging.arn
}