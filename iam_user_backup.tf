# aws_iam_user.backup:
resource "aws_iam_user" "backup" {
  name = "s3_backup"
  path = "/"
  tags = {
    "Associated rake task" = "bundle exec rake scihist:copy_database_to_s3"
    "Description"          = "Used by a Heroku scheduled job to put nightly backups of the Digital Collections database onto our S3 backup bucket."
    "See also"             = "https://dashboard.heroku.com/apps/scihist-digicoll-production/scheduler"
  }
  tags_all = {
    "Associated rake task" = "bundle exec rake scihist:copy_database_to_s3"
    "Description"          = "Used by a Heroku scheduled job to put nightly backups of the Digital Collections database onto our S3 backup bucket."
    "See also"             = "https://dashboard.heroku.com/apps/scihist-digicoll-production/scheduler"
  }
}