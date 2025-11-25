
resource "aws_iam_policy" "bedrock_invoke_model" {
  description = "Allows access to Bedrock InvokeModel"
  name        = "bedrock_invoke_model"
  path        = "/"
  policy = jsonencode(
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": "bedrock:InvokeModel",
          "Resource": "*"
        }
      ]
    }
  )
  tags = {
    "production" = ""
    "read"       = ""
  }
  tags_all = {
    "production" = ""
    "read"       = ""
  }
}
