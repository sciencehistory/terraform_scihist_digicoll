# Our S3 buckets for digital collections.
#
# The way terraform works, there is a lot of repeated identical content -- for instance identical
# lifecycle rules on all buckets, we found no great way in terraform to re-use.
#
# Note common patterns:
#
#  * all buckets should have terraform lifecycle.prevent_destroy set, so terraform won't try
#  to delete a bucket (and all it's contents!) ever.
#
#  * *PUBLIC* buckets also have a corresponding `aws_s3_bucket_policy` terraform resource
# to grant public access to all contents. This is partialy for legacy purposes, not
# all keys have public-read ACL's set individually but they are all meant to be public.
#
# * *PRIVATE* buckets also have a `aws_s3_bucket_public_access_block` terraform resourcce
# to tell S3 to *forbid* public access, a standard S3 safety measure.
#

#
# Our standard app-created derivatives, in a public bucket
#
resource "aws_s3_bucket" "derivatives" {
    bucket                      = "${local.name_prefix}-derivatives"

    lifecycle {
      prevent_destroy           = true
    }

    tags                        = {
        "service" = local.service_tag
        "use"     = "derivatives"
    }

    cors_rule {
        allowed_headers = [
            "*",
        ]
        allowed_methods = [
            "GET",
        ]
        allowed_origins = [
            "*",
        ]
        expose_headers  = []
        max_age_seconds = 43200
    }

    lifecycle_rule {
        enabled                                = true
        id                                     = "Expire previous files"

        noncurrent_version_expiration {
            days = 30
        }
    }
    lifecycle_rule {
        enabled                                = true
        id                                     = "scihist-digicoll-${terraform.workspace}-derivatives-IA-Rule"

        transition {
            days          = 30
            storage_class = "STANDARD_IA"
        }
    }

    versioning {
        enabled    = true
    }
}

resource "aws_s3_bucket_policy" "derivatives" {
    bucket = aws_s3_bucket.derivatives.id
    policy = templatefile("templates/s3_public_read_policy.tftpl", { bucket_name: aws_s3_bucket.derivatives.id })
}



#
# DZI tiles, in a public bucket. They are voluminous
#
resource "aws_s3_bucket" "dzi" {
    bucket                      = "${local.name_prefix}-dzi"

    lifecycle {
      prevent_destroy           = true
    }

    tags                        = {
        "service" = local.service_tag
        "use"     = "dzi"
    }

    cors_rule {
      allowed_headers = [
          "*",
      ]
      allowed_methods = [
          "GET",
      ]
      allowed_origins = [
          "*",
      ]
      expose_headers  = []
      max_age_seconds = 43200
    }

    lifecycle_rule {
        enabled                                = true
        id                                     = "Expire previous files"

        noncurrent_version_expiration {
            days = 30
        }
    }
    lifecycle_rule {
        enabled                                = true
        id                                     = "scihist-digicoll-${terraform.workspace}-dzi-IA-Rule"

        transition {
            days          = 30
            storage_class = "STANDARD_IA"
        }
    }

    versioning {
        enabled    = true
    }
}

resource "aws_s3_bucket_policy" "dzi" {
    bucket = aws_s3_bucket.dzi.id
    policy = templatefile("templates/s3_public_read_policy.tftpl", { bucket_name: aws_s3_bucket.dzi.id })
}







#
# S3 bucket that is "mounted" on windows desktops, so staff can copy files to it, for later
# ingest by app.
#
resource "aws_s3_bucket" "ingest_mount" {
    bucket                      = "${local.name_prefix}-ingest-mount"

    lifecycle {
      prevent_destroy           = true
    }

    tags                      = {
        "service" = local.service_tag
        "use"     = "upload"
    }

    cors_rule {
        allowed_headers = [
            "Authorization",
            "x-amz-date",
            "x-amz-content-sha256",
            "content-type",
        ]
        allowed_methods = [
            "GET",
            "POST",
            "PUT",
        ]
        allowed_origins = [
            "*",
        ]
        expose_headers  = [
            "ETag",
        ]
        max_age_seconds = 3000
    }

    lifecycle_rule {
        enabled                                = true
        id                                     = "Expire files"
        expiration {
            days                         = 30
            expired_object_delete_marker = false
        }
    }
    lifecycle_rule {
        enabled                                = true
        id                                     = "scihist-digicoll-${terraform.workspace}-ingest-mount-IA-Rule"

        transition {
            days          = 30
            storage_class = "STANDARD_IA"
        }
    }

    versioning {
        enabled    = false
    }
}

resource "aws_s3_bucket_public_access_block" "ingest_mount" {
  bucket = aws_s3_bucket.ingest_mount.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}



#
# A bucket just for our on-demand derivatives, serves as a kind of cache, has
# lifecycle rules to delete ones that haven't been accessed in a while.
#
# Doesn't need a public policy cause we just set public-read ACLs on individual objects.
resource "aws_s3_bucket"  "ondemand_derivatives" {
    bucket                      = "${local.name_prefix}-ondemand-derivatives"

    lifecycle {
      prevent_destroy           = true
    }

    tags                        = {
          "service" = local.service_tag
          "use"     = "cache"
    }

    lifecycle_rule {
        enabled                                = true
        id                                     = "Expire files"

        expiration {
            days                         = 20
            expired_object_delete_marker = false
        }
    }
    lifecycle_rule {
        enabled                                = true
        id                                     = "scihist-digicoll-${terraform.workspace}-ondemand-derivatives-IA-Rule"

        transition {
            days          = 30
            storage_class = "STANDARD_IA"
        }
    }

    versioning {
        enabled    = false
    }
}






#
# Original assets, as ingested, in a private bucket
#
resource "aws_s3_bucket" "originals" {
    bucket                      = "${local.name_prefix}-originals"

    lifecycle {
      prevent_destroy           = true
    }

    tags                        = {
        "service" = local.service_tag
        "use"     = "originals"
    }

    lifecycle_rule {
        enabled                                = true
        id                                     = "Expire previous files"
        noncurrent_version_expiration {
            days = 30
        }
    }

    lifecycle_rule {
        enabled                                = true
        id                                     = "scihist-digicoll-${terraform.workspace}-originals-IA-Rule"
        transition {
            days          = 30
            storage_class = "STANDARD_IA"
        }
    }

    versioning {
        enabled    = true
    }
}

resource "aws_s3_bucket_public_access_block" "originals" {
  bucket = aws_s3_bucket.originals.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}





#
# A public bucket intended for a variety of uses. Does not have versioning turned on at present.
#
resource "aws_s3_bucket" "public" {
    bucket                      = "${local.name_prefix}-public"

    lifecycle {
      prevent_destroy           = true
    }

    tags                        = {
        "service" = local.service_tag
        "use"     = "general_public"
    }

    versioning {
        enabled    = false
    }
}

resource "aws_s3_bucket_policy" "public" {
    bucket = aws_s3_bucket.public.id
    policy = templatefile("templates/s3_public_read_policy.tftpl", { bucket_name: aws_s3_bucket.public.id })
}




#
# A bucket to which our app's in-browser javascript uploads files to be ingested, so the
# back-end app can get them. Should NOT be public. Needs CORS tags to allow JS upload.
#
resource "aws_s3_bucket"  "uploads" {
    bucket = "${local.name_prefix}-uploads"

    lifecycle {
      prevent_destroy           = true
    }

    tags                        = {
        "service" = local.service_tag
        "use"     = "upload"
    }

    cors_rule {
        allowed_headers = [
            "Authorization",
            "x-amz-date",
            "x-amz-content-sha256",
            "content-type",
        ]
        allowed_methods = [
            "GET",
            "POST",
            "PUT",
        ]
        allowed_origins = [
            "*",
        ]
        expose_headers  = [
            "ETag",
        ]
        max_age_seconds = 3000
    }

    lifecycle_rule {
        enabled                                = true
        id                                     = "Expire files"

        expiration {
            days                         = 30
            expired_object_delete_marker = false
        }
    }
    lifecycle_rule {
        enabled                                = true
        id                                     = "scihist-digicoll-${terraform.workspace}-uploads-IA-Rule"

        transition {
            days          = 30
            storage_class = "STANDARD_IA"
        }
    }

    versioning {
        enabled    = false
    }
}

resource "aws_s3_bucket_public_access_block" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


