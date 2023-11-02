# Replication:
# terraform import aws_iam_role.S3-Backup-Replication S3-Backup-Replication
# aws_iam_role.S3-Backup-Replication:
resource "aws_iam_role" "S3-Backup-Replication" {
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "s3.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  description           = "Replication role for backing up data between thumbnail bucket in US-EAST and backup bucket in US-WEST. Does not replicate delete commands, so breaks the normal cross-region replication rule there. Deletes must be done manually."
  force_detach_policies = false
  managed_policy_arns = [
    "arn:aws:iam::335460257737:policy/s3crr_for_scihist-digicoll-production-originals-video_to_scihist-digicoll-production-originals-video-backup",
    "arn:aws:iam::335460257737:policy/service-role/s3crr_for_scihist-digicoll-production-derivatives_to_scihist-digicoll-production-derivatives-backup",
    "arn:aws:iam::335460257737:policy/service-role/s3crr_for_scihist-digicoll-production-dzi_to_scihist-digicoll-production-dzi-backup",
    "arn:aws:iam::335460257737:policy/service-role/s3crr_for_scihist-digicoll-production-originals_to_scihist-digicoll-production-originals-backup",
  ]
  max_session_duration = 3600
  name                 = "S3-Backup-Replication"
  path                 = "/"
  tags                 = {}
  tags_all             = {}
}

# Can't actually import these, as the names are too long.

# terraform import aws_iam_role.s3crr_for_scihist-digicoll-production-originals-video_to_scihist-digicoll-production-originals-video-backup s3crr_for_scihist-digicoll-production-originals-video_to_scihist-digicoll-production-originals-video-backup
# s3crr_for_scihist-digicoll-production-originals-video_to_scihist-digicoll-production-originals-video-backup
resource "aws_iam_role" "s3crr_for_scihist-digicoll-production-originals-video_to_scihist-digicoll-production-originals-video-backup" {
  name               = "s3crr_originals_video"
  assume_role_policy = jsonencode({})
}

# terraform import aws_iam_role.s3crr_for_scihist-digicoll-production-originals_to_scihist-digicoll-production-originals-backup s3crr_for_scihist-digicoll-production-originals_to_scihist-digicoll-production-originals-backup
# s3crr_for_scihist-digicoll-production-originals_to_scihist-digicoll-production-originals-backup
resource "aws_iam_role" "s3crr_for_scihist-digicoll-production-originals_to_scihist-digicoll-production-originals-backup" {
  name               = "s3crr_originals"
  assume_role_policy = jsonencode({})
}

# terraform import aws_iam_role.s3crr_for_scihist-digicoll-production-dzi_to_scihist-digicoll-production-dzi-backup s3crr_for_scihist-digicoll-production-dzi_to_scihist-digicoll-production-dzi-backup
# s3crr_for_scihist-digicoll-production-dzi_to_scihist-digicoll-production-dzi-backup
resource "aws_iam_role" "s3crr_for_scihist-digicoll-production-dzi_to_scihist-digicoll-production-dzi-backup" {
  name               = "s3crr_dzi"
  assume_role_policy = jsonencode({})
}
# terraform import aws_iam_role.s3crr_for_scihist-digicoll-production-derivatives_to_scihist-digicoll-production-derivatives-backup s3crr_for_scihist-digicoll-production-derivatives_to_scihist-digicoll-production-derivatives-backup
# s3crr_for_scihist-digicoll-production-derivatives_to_scihist-digicoll-production-derivatives-backup
resource "aws_iam_role" "s3crr_for_scihist-digicoll-production-derivatives_to_scihist-digicoll-production-derivatives-backup" {
  name = "s3crr_derivatives"

  assume_role_policy = jsonencode({})

}