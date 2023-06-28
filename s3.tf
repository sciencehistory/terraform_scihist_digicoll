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
  bucket = "${local.name_prefix}-derivatives"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    "service"        = local.service_tag
    "use"            = "derivatives"
    "S3-Bucket-Name" = "${local.name_prefix}-derivatives"
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
          bucket = one(aws_s3_bucket.derivatives_backup).arn
        }
      }
    }
  }

}

resource "aws_s3_bucket_policy" "derivatives" {
  bucket = aws_s3_bucket.derivatives.id
  policy = templatefile("templates/s3_public_read_policy.tftpl", { bucket_name : aws_s3_bucket.derivatives.id })
}

resource "aws_s3_bucket_cors_configuration" "derivatives" {

  bucket = aws_s3_bucket.derivatives.id

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
}


resource "aws_s3_bucket_lifecycle_configuration" "derivatives" {
  bucket = aws_s3_bucket.derivatives.id
  rule {
    status = "Enabled"
    id     = "Expire previous files"

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
  rule {
    status = "Enabled"
    id     = "scihist-digicoll-${terraform.workspace}-derivatives-IT-Rule"

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "INTELLIGENT_TIERING"
    }
  }
}

resource "aws_s3_bucket_versioning" "derivatives" {
  bucket = aws_s3_bucket.derivatives.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "derivatives" {
  bucket = aws_s3_bucket.derivatives.id

  rule {
    bucket_key_enabled = false
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Video derivatives, expected to be mainly/only HLS. Set up in a separate bucket from
# other videos for easier cost tracking. Also the method of creation/management differs.
#
# Set up to mimic the derivatives bucket.
#
# * EXCEPT: We've decided NOT to replicate to a backup bucket.
# * NOTE: This is intentionally set to publically readable -- like our other
#   derivatives bucket. In this case, signed URLs wouldn't work for HLS files,
#   as the manifest files have references to static urls in them too.
resource "aws_s3_bucket" "derivatives_video" {
  bucket = "${local.name_prefix}-derivatives-video"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    "service"        = local.service_tag
    "use"            = "derivatives"
    "S3-Bucket-Name" = "${local.name_prefix}-derivatives-video"
  }
}

resource "aws_s3_bucket_cors_configuration" "derivatives_video" {

  bucket = "${local.name_prefix}-derivatives-video"

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
}

resource "aws_s3_bucket_policy" "derivatives-video" {
  bucket = aws_s3_bucket.derivatives_video.id
  policy = templatefile("templates/s3_public_read_policy.tftpl", { bucket_name : aws_s3_bucket.derivatives_video.id })
}

resource "aws_s3_bucket_lifecycle_configuration" "derivatives_video" {
  bucket = aws_s3_bucket.derivatives_video.id

  rule {
    status = "Enabled"
    id     = "Expire previous files"

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
  rule {
    status = "Enabled"
    id     = "scihist-digicoll-${terraform.workspace}-derivatives-IT-Rule"

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "INTELLIGENT_TIERING"
    }
  }
}

resource "aws_s3_bucket_versioning" "derivatives_video" {
  bucket = aws_s3_bucket.derivatives_video.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "derivatives_video" {
  bucket = aws_s3_bucket.derivatives_video.id

  rule {
    bucket_key_enabled = false
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#
# DZI tiles, in a public bucket. They are voluminous
#
# Replication only in production.
resource "aws_s3_bucket" "dzi" {
  bucket = "${local.name_prefix}-dzi"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    "service"        = local.service_tag
    "use"            = "dzi"
    "S3-Bucket-Name" = "${local.name_prefix}-dzi"
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
          bucket = one(aws_s3_bucket.dzi_backup).arn
        }
      }
    }
  }
}

resource "aws_s3_bucket_policy" "dzi" {
  bucket = aws_s3_bucket.dzi.id
  policy = templatefile("templates/s3_public_read_policy.tftpl", { bucket_name : aws_s3_bucket.dzi.id })
}

resource "aws_s3_bucket_cors_configuration" "dzi" {

  bucket = aws_s3_bucket.dzi.id

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
}

resource "aws_s3_bucket_lifecycle_configuration" "dzi" {
  bucket = aws_s3_bucket.dzi.id

  rule {
    status = "Enabled"
    id     = "Expire previous files"

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }

  rule {
    status = "Enabled"
    id     = "scihist-digicoll-${terraform.workspace}-dzi-IT-Rule"

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "INTELLIGENT_TIERING"
    }
  }
}

resource "aws_s3_bucket_versioning" "dzi" {
  bucket = aws_s3_bucket.dzi.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "dzi" {
  bucket = aws_s3_bucket.dzi.id

  rule {
    bucket_key_enabled = false
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#
# S3 bucket that is "mounted" on windows desktops, so staff can copy files to it, for later
# ingest by app.
#
resource "aws_s3_bucket" "ingest_mount" {
  bucket = "${local.name_prefix}-ingest-mount"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    "service"        = local.service_tag
    "use"            = "upload"
    "S3-Bucket-Name" = "${local.name_prefix}-ingest-mount"
  }



}

resource "aws_s3_bucket_public_access_block" "ingest_mount" {
  bucket = aws_s3_bucket.ingest_mount.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_cors_configuration" "ingest_mount" {

  bucket = aws_s3_bucket.ingest_mount.id

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
    expose_headers = [
      "ETag",
    ]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "ingest_mount" {
  bucket = aws_s3_bucket.ingest_mount.id

  rule {
    status = "Disabled"
    id     = "Expire files"

    expiration {
      days                         = 30
      expired_object_delete_marker = false
    }
  }

  rule {
    status = "Enabled"
    id     = "scihist-digicoll-${terraform.workspace}-ingest-mount-IA-Rule"

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }
  }
}

resource "aws_s3_bucket_versioning" "ingest_mount" {
  bucket = aws_s3_bucket.ingest_mount.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ingest_mount" {
  bucket = aws_s3_bucket.ingest_mount.id

  rule {
    bucket_key_enabled = false
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#
# A bucket just for our on-demand derivatives, serves as a kind of cache, has
# lifecycle rules to delete ones that haven't been accessed in a while.
#
# Doesn't need a public policy cause we just set public-read ACLs on individual objects.
resource "aws_s3_bucket" "ondemand_derivatives" {
  bucket = "${local.name_prefix}-ondemand-derivatives"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    "service"        = local.service_tag
    "use"            = "cache"
    "S3-Bucket-Name" = "${local.name_prefix}-ondemand-derivatives"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "ondemand_derivatives" {
  bucket = "${local.name_prefix}-ondemand-derivatives"

  rule {
    status = "Enabled"
    id     = "Expire files"

    expiration {
      days                         = 20
      expired_object_delete_marker = false
    }
  }

  rule {
    status = "Enabled"
    id     = "scihist-digicoll-${terraform.workspace}-ondemand-derivatives-IA-Rule"

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }
  }
}

resource "aws_s3_bucket_versioning" "ondemand_derivatives" {
  bucket = aws_s3_bucket.ondemand_derivatives.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ondemand_derivatives" {
  bucket = aws_s3_bucket.ondemand_derivatives.id

  rule {
    bucket_key_enabled = false
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#
# Original assets, as ingested, in a private bucket
#
# Replication rule only for production.
#
resource "aws_s3_bucket" "originals" {
  bucket = "${local.name_prefix}-originals"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    "service"        = local.service_tag
    "use"            = "originals"
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
          bucket = one(aws_s3_bucket.originals_backup).arn
        }
      }
    }
  }

  # logging {
  #    target_bucket = "chf-logs"
  #    target_prefix = "s3_server_access_${terraform.workspace}_originals/"
  # }
}

resource "aws_s3_bucket_public_access_block" "originals" {
  bucket = aws_s3_bucket.originals.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "originals" {
  bucket = "${local.name_prefix}-originals"

  rule {
    status = "Enabled"
    id     = "Expire previous files"

    expiration {
      days = 30
    }
  }

  rule {
    status = "Enabled"
    id     = "scihist-digicoll-${terraform.workspace}-originals-IT-Rule"

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "INTELLIGENT_TIERING"
    }
  }
}

resource "aws_s3_bucket_versioning" "originals" {
  bucket = aws_s3_bucket.originals.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "originals" {
  bucket = aws_s3_bucket.originals.id

  rule {
    bucket_key_enabled = false
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#
# Original VIDEO assets, as ingested, in a private bucket, separate bucket for videos.
#
# Replication rule only for production.
#
resource "aws_s3_bucket" "originals_video" {
  bucket = "${local.name_prefix}-originals-video"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    "service"        = local.service_tag
    "use"            = "originals"
    "S3-Bucket-Name" = "${local.name_prefix}-originals-video"
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
          bucket = one(aws_s3_bucket.originals_video_backup).arn
        }
      }
    }
  }

  # logging {
  #    target_bucket = "chf-logs"
  #    target_prefix = "s3_server_access_${terraform.workspace}_originals_video/"
  # }
}

resource "aws_s3_bucket_public_access_block" "originals_video" {
  bucket = aws_s3_bucket.originals_video.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "originals_video" {
  bucket = "${local.name_prefix}-originals-video"



  rule {
    status = "Enabled"
    id     = "Expire previous files"

    expiration {
      days = 30
    }
  }

  rule {
    status = "Enabled"
    id     = "scihist-digicoll-${terraform.workspace}-originals-video-IT-Rule"

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "INTELLIGENT_TIERING"
    }
  }
}

resource "aws_s3_bucket_versioning" "originals_video" {
  bucket = aws_s3_bucket.originals_video.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "originals_video" {
  bucket = aws_s3_bucket.originals_video.id

  rule {
    bucket_key_enabled = false
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
#
# A public bucket intended for a variety of uses. Does not have versioning turned on at present.
#
resource "aws_s3_bucket" "public" {
  bucket = "${local.name_prefix}-public"

  lifecycle {
    prevent_destroy = true
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

#
# A bucket to which our app's in-browser javascript uploads files to be ingested, so the
# back-end app can get them. Should NOT be public. Needs CORS tags to allow JS upload.
#
resource "aws_s3_bucket" "uploads" {
  bucket = "${local.name_prefix}-uploads"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    "service"        = local.service_tag
    "use"            = "upload"
    "S3-Bucket-Name" = "${local.name_prefix}-uploads"
  }
}

resource "aws_s3_bucket_public_access_block" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_cors_configuration" "uploads" {

  bucket = aws_s3_bucket.uploads.id

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
    expose_headers = [
      "ETag",
    ]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "uploads" {
  bucket = "${local.name_prefix}-uploads"

  rule {
    status = "Enabled"
    id     = "Expire files"

    expiration {
      days = 30
    }
  }

  rule {
    status = "Enabled"
    id     = "scihist-digicoll-${terraform.workspace}-uploads-IA-Rule"

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }
  }
}

resource "aws_s3_bucket_versioning" "uploads" {
  bucket = aws_s3_bucket.uploads.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  rule {
    bucket_key_enabled = false
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

###
#
# BACKUP BUCKETS, *** only in production ***
#
###

resource "aws_s3_bucket" "derivatives_backup" {
  count    = terraform.workspace == "production" ? 1 : 0
  provider = aws.backup

  bucket = "${local.name_prefix}-derivatives-backup"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    "service"        = local.service_tag
    "use"            = "derivatives"
    "S3-Bucket-Name" = "${local.name_prefix}-derivatives-backup"
  }
}

resource "aws_s3_bucket_policy" "derivatives_backup" {
  count    = terraform.workspace == "production" ? 1 : 0
  provider = aws.backup

  bucket = aws_s3_bucket.derivatives_backup[0].id
  policy = templatefile("templates/s3_public_read_policy.tftpl", { bucket_name : aws_s3_bucket.derivatives_backup[0].id })
}

resource "aws_s3_bucket_cors_configuration" "derivatives_backup" {

  count  = terraform.workspace == "production" ? 1 : 0
  bucket = aws_s3_bucket.derivatives_backup[0].id

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
}

resource "aws_s3_bucket_lifecycle_configuration" "derivatives_backup" {
  count  = terraform.workspace == "production" ? 1 : 0
  bucket = "${local.name_prefix}-derivatives-backup"

  rule {
    status = "Enabled"
    id     = "Expire previous files"

    expiration {
      days = 30
    }
  }
  rule {
    status = "Enabled"
    id     = "scihist-digicoll-${terraform.workspace}-derivatives-backup-IA-Rule"

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }
  }
}

resource "aws_s3_bucket_versioning" "derivatives_backup" {
  count  = terraform.workspace == "production" ? 1 : 0
  bucket = aws_s3_bucket.derivatives_backup[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "derivatives_backup" {

  count  = terraform.workspace == "production" ? 1 : 0
  bucket = aws_s3_bucket.derivatives_backup[0].id

  rule {
    bucket_key_enabled = false
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket" "dzi_backup" {
  count    = terraform.workspace == "production" ? 1 : 0
  provider = aws.backup

  bucket = "${local.name_prefix}-dzi-backup"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    "service"        = "kithe"
    "use"            = "dzi"
    "S3-Bucket-Name" = "${local.name_prefix}-dzi-backup"
  }
}

resource "aws_s3_bucket_policy" "dzi_backup" {
  count    = terraform.workspace == "production" ? 1 : 0
  provider = aws.backup

  bucket = aws_s3_bucket.dzi_backup[0].id
  policy = templatefile("templates/s3_public_read_policy.tftpl", { bucket_name : aws_s3_bucket.dzi_backup[0].id })
}

resource "aws_s3_bucket_cors_configuration" "dzi_backup" {

  count  = terraform.workspace == "production" ? 1 : 0
  bucket = aws_s3_bucket.dzi_backup[0].id

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
}

resource "aws_s3_bucket_lifecycle_configuration" "dzi_backup" {
  count  = terraform.workspace == "production" ? 1 : 0
  bucket = "${local.name_prefix}-dzi-backup"

  rule {
    status = "Enabled"
    id     = "Expire previous files"

    expiration {
      days = 30
    }
  }
  rule {
    status = "Enabled"
    id     = "scihist-digicoll-production-dzi-backup-IA-Rule"

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "dzi_backup" {
  count  = terraform.workspace == "production" ? 1 : 0
  bucket = "${local.name_prefix}-dzi-backup"

  rule {
    bucket_key_enabled = false
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket" "originals_backup" {
  count    = terraform.workspace == "production" ? 1 : 0
  provider = aws.backup

  bucket = "${local.name_prefix}-originals-backup"

  tags = {
    "service"        = "kithe"
    "use"            = "originals"
    "S3-Bucket-Name" = "${local.name_prefix}-originals-backup"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "originals_backup" {
  count  = terraform.workspace == "production" ? 1 : 0
  bucket = "${local.name_prefix}-originals-backup"


  rule {
    status = "Enabled"
    id     = "Expire previous files"

    expiration {
      days = 30
    }
  }
  rule {
    status = "Enabled"
    id     = "Scihist-digicoll-production-originals-backup_Lifecycle"

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }
  }
}

resource "aws_s3_bucket_versioning" "originals_backup" {
  count  = terraform.workspace == "production" ? 1 : 0
  bucket = aws_s3_bucket.originals_backup[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "originals_backup" {
  count  = terraform.workspace == "production" ? 1 : 0
  bucket = aws_s3_bucket.originals_backup[0].id

  rule {
    bucket_key_enabled = false
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket" "originals_video_backup" {
  count    = terraform.workspace == "production" ? 1 : 0
  provider = aws.backup

  bucket = "${local.name_prefix}-originals-video-backup"

  tags = {
    "service"        = "kithe"
    "use"            = "originals"
    "S3-Bucket-Name" = "${local.name_prefix}-originals-video-backup"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "originals_video_backup" {
  count  = terraform.workspace == "production" ? 1 : 0
  bucket = "${local.name_prefix}-originals-video-backup"

  rule {
    status = "Enabled"
    id     = "Expire previous files"

    expiration {
      days = 30
    }
  }

  rule {
    status = "Enabled"
    id     = "${local.name_prefix}-originals-video-backup_Lifecycle"

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }
  }
}

resource "aws_s3_bucket_versioning" "originals_video_backup" {
  count  = terraform.workspace == "production" ? 1 : 0
  bucket = aws_s3_bucket.originals_video_backup[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "originals_video_backup" {
  count  = terraform.workspace == "production" ? 1 : 0
  bucket = aws_s3_bucket.originals_video_backup[0].id
  rule {
    bucket_key_enabled = false
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
