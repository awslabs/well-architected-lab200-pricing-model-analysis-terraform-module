
resource "aws_iam_role" "SPToolS3Lambda" {
  name = "SPToolS3Lambda${var.env}"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "sid1"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

}


resource "aws_iam_role_policy" "S3PricingLambdaPolicy" {
  name = "S3PricingLambdaPolicy${var.env}"
  role = aws_iam_role.SPToolS3Lambda.id

  policy = <<EOF
{
    "Version":"2012-10-17",
    "Statement":[
        {
            "Sid":"S3Org",
            "Effect":"Allow",
            "Action":[
                "s3:PutObject",
                "s3:DeleteObjectVersion",
                "s3:DeleteObject"
            ],
            "Resource":"arn:aws:s3:::${aws_s3_bucket.s3_bucket.id}/*"
        }
    ]
}
EOF
}
