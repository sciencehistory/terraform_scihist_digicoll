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
# * Tag "S3-Bucket-Name" -- all buckets should have a tag "S3-Bucket-Name" that contains
# their same bucket name, this duplication is useful for various cost analysis. Unfortunately,
# terraform makes us duplicate the calculation of bucket name in the tag definition, see
# https://github.com/hashicorp/terraform/issues/23966
#
# Our standard app-created derivatives, in a public bucket
#
# Replication only in production.
#
resource "aws_s3_bucket" "derivatives" {
    bucket                      = "${local.name_prefix}-derivatives"

    lifecycle {
      prevent_destroy           = true
    }

    tags                        = {
        "service" = local.service_tag
        "use"     = "derivatives"
        "S3-Bucket-Name" = "${local.name_prefix}-derivatives"
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

    # only Enabled for production.
    dynamic "replication_configuration" {
        // hacky way to make this conditional, once and only once on production.
        for_each = terraform.workspace == "production" ? [1] : []
        content {
            # we're not controlling the IAM role with terraform, so we just hardcode it for now.
            role = "arn:aws:iam::335460257737:role/S3-Backup-Replication"

            rules {
                id       = "Backup"
                priority = 0
                status   = "Enabled"

                destination {
                    bucket = "arn:aws:s3:::scihist-digicoll-${terraform.workspace}-derivatives-backup"
                }
            }
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
# Replication only in production.
resource "aws_s3_bucket" "dzi" {
    bucket                      = "${local.name_prefix}-dzi"

    lifecycle {
      prevent_destroy           = true
    }

    tags                        = {
        "service" = local.service_tag
        "use"     = "dzi"
        "S3-Bucket-Name" = "${local.name_prefix}-dzi"
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

    # only Enabled for production.
    dynamic "replication_configuration" {
        // hacky way to make this conditional, once and only once on production.
        for_each = terraform.workspace == "production" ? [1] : []

        content {
            # we're not controlling the IAM role with terraform, so we just hardcode it for now.
            role = "arn:aws:iam::335460257737:role/S3-Backup-Replication"

            rules {
                id       = "Backup"
                priority = 0
                status   = "Enabled"

                destination {
                    bucket = "arn:aws:s3:::scihist-digicoll-${terraform.workspace}-dzi-backup"
                }
            }
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
        "S3-Bucket-Name" = "${local.name_prefix}-ingest-mount"
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
        enabled                                = false
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
          "S3-Bucket-Name" = "${local.name_prefix}-ondemand-derivatives"
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
# Replication rule only for production.
#
resource "aws_s3_bucket" "originals" {
    bucket                      = "${local.name_prefix}-originals"

    lifecycle {
      prevent_destroy           = true
    }

    tags                        = {
        "service" = local.service_tag
        "use"     = "originals"
        "S3-Bucket-Name" = "${local.name_prefix}-originals"
    }

    # only Enabled for production.
    dynamic "replication_configuration" {
        // hacky way to make this conditional, once and only once on production.
        for_each = terraform.workspace == "production" ? [1] : []

        content {
            # we're not controlling the IAM role with terraform, so we just hardcode it for now.
            role = "arn:aws:iam::335460257737:role/S3-Backup-Replication"

            rules {
                id       = "Backup"
                priority = 0
                status   = "Enabled"

                destination {
                    bucket = "arn:aws:s3:::scihist-digicoll-${terraform.workspace}-originals-backup"
                }
            }
        }
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
        "S3-Bucket-Name" = "${local.name_prefix}-public"
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
        "S3-Bucket-Name" = "${local.name_prefix}-uploads"
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



###
#
# BACKUP BUCKETS, *** only in production ***
#
###

resource "aws_s3_bucket"  "derivatives_backup" {
    count = "${terraform.workspace == "production" ? 1 : 0}"
    provider = aws.backup

    bucket = "${local.name_prefix}-derivatives-backup"

    lifecycle {
      prevent_destroy           = true
    }

    tags                        = {
        "service" = local.service_tag
        "use"     = "derivatives"
        "S3-Bucket-Name" = "${local.name_prefix}-derivatives-backup"
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
        id                                     = "scihist-digicoll-${terraform.workspace}-derivatives-backup-IA-Rule"

        transition {
            days          = 30
            storage_class = "STANDARD_IA"
        }
    }

    versioning {
        enabled    = true
    }
}

resource "aws_s3_bucket_policy" "derivatives_backup" {
    count = "${terraform.workspace == "production" ? 1 : 0}"
    provider = aws.backup

    bucket = aws_s3_bucket.derivatives_backup[0].id
    policy = templatefile("templates/s3_public_read_policy.tftpl", { bucket_name: aws_s3_bucket.derivatives_backup[0].id })
}


resource "aws_s3_bucket"  "dzi_backup" {
    count = "${terraform.workspace == "production" ? 1 : 0}"
    provider = aws.backup

    bucket = "${local.name_prefix}-dzi-backup"

    lifecycle {
      prevent_destroy           = true
    }

    tags                        = {
        "service" = "kithe"
        "use"     = "dzi"
        "S3-Bucket-Name" = "${local.name_prefix}-dzi-backup"
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
        id                                     = "scihist-digicoll-production-dzi-backup-IA-Rule"

        transition {
            days          = 30
            storage_class = "STANDARD_IA"
        }
    }
}

resource "aws_s3_bucket_policy" "dzi_backup" {
    count = "${terraform.workspace == "production" ? 1 : 0}"
    provider = aws.backup

    bucket = aws_s3_bucket.dzi_backup[0].id
    policy = templatefile("templates/s3_public_read_policy.tftpl", { bucket_name: aws_s3_bucket.dzi_backup[0].id })
}

resource "aws_s3_bucket"  "originals_backup" {
    count = "${terraform.workspace == "production" ? 1 : 0}"
    provider = aws.backup

    bucket = "${local.name_prefix}-originals-backup"

    tags                        = {
        "service" = "kithe"
        "use"     = "originals"
        "S3-Bucket-Name" = "${local.name_prefix}-originals-backup"
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
        id                                     = "Scihist-digicoll-production-originals-backup_Lifecycle"

        transition {
            days          = 30
            storage_class = "STANDARD_IA"
        }
    }
}

