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
#
# The configuration for the actual s3 bucket is now in bucket_terraform_state.tf .

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
