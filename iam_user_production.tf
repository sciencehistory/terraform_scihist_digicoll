# aws_iam_user.production:
resource "aws_iam_user" "production" {
  name = "s3_digicoll_production"
  path = "/"
  tags = {
    "Description" = "Used by the production app on Heroku to access all the s3 buckets it needs."
  }
  tags_all = {
    "Description" = "Used by the production app on Heroku to access all the s3 buckets it needs."
  }
}