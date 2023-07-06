#
# A public bucket intended for a variety of uses. Does not have versioning turned on at present.
#
resource "aws_s3_bucket" "public" {
  bucket = "${local.name_prefix}-public"

  lifecycle {
    prevent_destroy = true
    # Workaround:
    # See https://github.com/hashicorp/terraform-provider-aws/issues/25241
    # Can remove this ignore_changes after we move to AWS Provider 4.x
    ignore_changes = [
      cors_rule,
      lifecycle_rule
    ]
  }

  tags = {
    "service"        = local.service_tag
    "use"            = "general_public"
    "S3-Bucket-Name" = "${local.name_prefix}-public"
  }
}

resource "aws_s3_bucket_versioning" "public" {
  bucket = aws_s3_bucket.public.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_policy" "public" {
  bucket = aws_s3_bucket.public.id
  policy = templatefile("templates/s3_public_read_policy.tftpl", { bucket_name : aws_s3_bucket.public.id })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "public" {
  bucket = aws_s3_bucket.public.id

  rule {
    bucket_key_enabled = false
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
