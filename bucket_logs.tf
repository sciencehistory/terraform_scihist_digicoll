# This bucket is shared by both production and staging at present....

# this terraform config is not right in that both staging and prod terraform workspaces currently think
# they control this same bucket. Should prob fix, but it's worked up to now and am not fixing right now.

resource "aws_s3_bucket" "chf-logs" {
  force_destroy = false
  bucket        = "chf-logs"
  tags = {
    "Role"           = "Production"
    "S3-Bucket-Name" = "chf-logs"
    "Service"        = "Systems"
    "Type"           = "S3"
  }
}
