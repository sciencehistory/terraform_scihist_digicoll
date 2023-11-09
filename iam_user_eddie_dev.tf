# aws_iam_user.eddie_dev:
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