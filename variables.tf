# Terraform variables can be overridden from defaults by the caller by several
# means, including a .tvvars file, the terraform command line, or special
# TV_VARS_* ENV variables. https://www.terraform.io/docs/language/values/variables.html

variable "aws_region" {
  default = "us-east-1"
}

variable "aws_backup_region" {
  default = "us-west-2"
}
