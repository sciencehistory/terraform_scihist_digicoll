# configure our terraform backend to use shared state on S3, as
# configured in shared_state_s3.tf

terraform {
  backend "s3" {
    # can't use terraform variable in backend config, have to hard-code this!
    # can still be overridden with AWS_PROFILE shell env though.
    profile = "admin"

    bucket = "scihist-digicoll-terraform-state"
    region = "us-east-1"
    key = "scihist-digicoll/terraform.tfstate"
    dynamodb_table = "scihist-digicoll-terraform-state-locks"
    encrypt = true
  }
}
