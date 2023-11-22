# aws_iam_user.email:
resource "aws_iam_user" "email" {
  name = "ses-smtp-user.20200807-125501"
  path = "/"
  tags = {
    "description" = "Used to send emails via SES from the digital collection."
  }
  tags_all = {
    "description" = "Used to send emails via SES from the digital collection."
  }
}