# terraform locals are essentially constants.
# https://www.terraform.io/docs/language/values/locals.html

locals {
  name_prefix = "scihist-digicoll-${terraform.workspace}"

  service_tag = "kithe"

  # this should probably match the profile in backend, which has
  # to be a literal. Unless you have some reason to want to use
  # different aws credentials with backend vs aws configured resources?
  # That seems like trouble.
  aws_access_profile = "admin"
}


