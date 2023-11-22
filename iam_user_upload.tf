# aws_iam_user.upload:
resource "aws_iam_user" "upload" {
  name     = "upload"
  path     = "/"
  tags     = {}
  tags_all = {}
}

# terraform import aws_iam_user.upload upload