#See also iam_user_email.tf

# terraform import aws_ses_domain_identity.sciencehistory sciencehistory.org
resource "aws_ses_domain_identity" "sciencehistory" {
  domain = "sciencehistory.org"
}

#terraform import aws_ses_domain_dkim.sciencehistory sciencehistory.org
resource "aws_ses_domain_dkim" "sciencehistory" {
  domain = aws_ses_domain_identity.sciencehistory.domain
}
