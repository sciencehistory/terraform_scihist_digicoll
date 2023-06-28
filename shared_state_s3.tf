# Setup for the terraform shared state back-end being on S3, including
# a dynamodb table for locking.
#
# Obviously we ran this before we actually configured the backend.
#
# See: https://mohitgoyal.co/2020/09/30/upload-terraform-state-files-to-remote-backend-amazon-s3-and-azure-storage-account/
#
# NOTE: Our use of the "workspace" feature.... since we are using workspaces for separating production
# and staging, but we only have ONE terraform-state infrastructure, we put it only in production
# using 'count'.
#
# If you want to deploy changes to these with terraform, you have to apply them in `production` workspace.

resource "aws_s3_bucket" "terraform_state" {
  bucket = "scihist-digicoll-terraform-state"

  count = terraform.workspace == "production" ? 1 : 0

  tags = {
    "service"        = local.service_tag
    "use"            = "terraform"
    "S3-Bucket-Name" = "scihist-digicoll-terraform-state"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  # Enable versioning so we can see the full revision history of our
  # state files
  bucket = aws_s3_bucket.terraform_state[0].id
  count  = terraform.workspace == "production" ? 1 : 0
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state[0].id

  count = terraform.workspace == "production" ? 1 : 0

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}



resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state[0].id
  count  = terraform.workspace == "production" ? 1 : 0
  # Enable server-side encryption by default
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_state_locks" {
  name = "scihist-digicoll-terraform-state-locks"

  count = terraform.workspace == "production" ? 1 : 0

  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  tags = {
    "service" = local.service_tag
    "use"     = "terraform"
  }

  attribute {
    name = "LockID"
    type = "S"
  }
}
