# configure our terraform backend to use shared state on S3, as
# configured in shared_state_s3.tf

terraform {
  backend "s3" {
    bucket = "scihist-digicoll-terraform-state"
    region = "us-east-1"
    key = "scihist-digicoll/terraform.tfstate"
    dynamodb_table = "scihist-digicoll-terraform-state-locks"
    encrypt = true
  }
}
