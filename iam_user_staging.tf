# aws_iam_user.staging:
resource "aws_iam_user" "staging" {
  name = "s3_digicoll_staging"
  path = "/"
  tags = {
    "Description" = "Used by the staging app on Heroku to access all the s3 buckets it needs."
  }
  tags_all = {
    "Description" = "Used by the staging app on Heroku to access all the s3 buckets it needs."
  }
}