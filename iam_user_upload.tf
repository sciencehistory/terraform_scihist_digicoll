# aws_iam_user.upload:
resource "aws_iam_user" "upload" {
  name     = "upload"
  path     = "/"
  tags     = {}
  tags_all = {}
}
