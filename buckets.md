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