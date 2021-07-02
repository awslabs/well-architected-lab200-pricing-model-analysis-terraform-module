

resource "aws_glue_crawler" "OD_Pricing" {
  database_name = "${var.pricing_db_name}${var.env}"
  name          = "od_pricing${var.env}"
  role          = aws_iam_role.SPToolPricing.arn

  s3_target {
    path = "s3://${aws_s3_bucket.s3_bucket.id}/Pricing/od_pricedata"
  }
}

resource "aws_glue_crawler" "SP_Pricing" {
  database_name = "${var.pricing_db_name}${var.env}"
  name          = "sp_pricing${var.env}"
  role          = aws_iam_role.SPToolPricing.arn

  s3_target {
    path = "s3://${aws_s3_bucket.s3_bucket.id}/Pricing/sp_pricedata"
  }

}

resource "aws_iam_role_policy" "SPToolPricing_policy" {
  name = "SPToolPricing_Policy${var.env}"
  role = aws_iam_role.SPToolPricing.id

  policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
{
"Effect": "Allow",
"Action": [
"glue:*",
"s3:GetBucketLocation",
"s3:ListBucket",
"s3:ListAllMyBuckets",
"s3:GetBucketAcl",
"ec2:DescribeVpcEndpoints",
"ec2:DescribeRouteTables",
"ec2:CreateNetworkInterface",
"ec2:DeleteNetworkInterface",
"ec2:DescribeNetworkInterfaces",
"ec2:DescribeSecurityGroups",
"ec2:DescribeSubnets",
"ec2:DescribeVpcAttribute",
"iam:ListRolePolicies",
"iam:GetRole",
"iam:GetRolePolicy",
"cloudwatch:PutMetricData"
],
"Resource": [
"*"
]
},
{
"Effect": "Allow",
"Action": [
"s3:CreateBucket"
],
"Resource": [
"arn:aws:s3:::aws-glue-*"
]
},
{
"Effect": "Allow",
"Action": [
"s3:GetObject",
"s3:PutObject",
"s3:DeleteObject"
],
"Resource": [
"arn:aws:s3:::aws-glue-*/*",
"arn:aws:s3:::*/*aws-glue-*/*"
]
},
{
"Effect": "Allow",
"Action": [
"s3:GetObject"
],
"Resource": [
"arn:aws:s3:::crawler-public*",
"arn:aws:s3:::aws-glue-*"
]
},
{
"Effect": "Allow",
"Action": [
"logs:CreateLogGroup",
"logs:CreateLogStream",
"logs:PutLogEvents"
],
"Resource": [
"arn:aws:logs:*:*:/aws-glue/*"
]
},
{
"Effect": "Allow",
"Action": [
"ec2:CreateTags",
"ec2:DeleteTags"
],
"Condition": {
"ForAllValues:StringEquals": {
"aws:TagKeys": [
"aws-glue-service-resource"
]
}
},
"Resource": [
"arn:aws:ec2:*:*:network-interface/*",
"arn:aws:ec2:*:*:security-group/*",
"arn:aws:ec2:*:*:instance/*"
]
},
{
"Effect": "Allow",
"Action": [
"s3:GetObject",
"s3:PutObject"
],
"Resource": [
"arn:aws:s3:::${aws_s3_bucket.s3_bucket.id}/*"
]
}
]
}
EOF

}

resource "aws_iam_role" "SPToolPricing" {
  name = "SPToolPricing${var.env}"

  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
{
"Effect": "Allow",
"Principal": {
"Service": "glue.amazonaws.com"
},
"Action": "sts:AssumeRole"
}
]
}
EOF

}

