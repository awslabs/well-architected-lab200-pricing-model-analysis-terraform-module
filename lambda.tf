# SPTool_ODPricing_Download
data "archive_file" "sp_od_pricing_zip" {
  type        = "zip"
  source_file = "${path.module}/source/sptool_odpricing_download.py"
  output_path = "${path.module}/output/sp_od_pricing.zip"
}

resource "aws_lambda_function" "sp_od_pricing" {
  filename         = "${path.module}/output/sp_od_pricing.zip"
  function_name    = "SPTool_ODPricing_Download${var.env}"
  role             = aws_iam_role.SPToolS3Lambda.arn
  handler          = "sptool_odpricing_download.lambda_handler"
  source_code_hash = data.archive_file.sp_od_pricing_zip.output_base64sha256
  runtime          = "python3.8"
  memory_size      = "4096"
  timeout          = "150"

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.s3_bucket.id
    }
  }

}

resource "aws_lambda_permission" "allow_cloudwatch_sp_od_pricing" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sp_od_pricing.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.sp_od_pricing_cloudwatch_rule.arn
  source_account = data.aws_caller_identity.current.account_id
}

resource "aws_cloudwatch_event_rule" "sp_od_pricing_cloudwatch_rule" {
  name                = "sp_od_pricing_lambda_trigger"
  schedule_expression = var.weekly_cron
}

resource "aws_cloudwatch_event_target" "sp_od_pricing_lambda" {
  rule      = aws_cloudwatch_event_rule.sp_od_pricing_cloudwatch_rule.name
  target_id = "sp_od_pricing_lambda_target"
  arn       = aws_lambda_function.sp_od_pricing.arn
}

# SPTool_SPPricing_Download
data "archive_file" "sp_sp_pricing_zip" {
  type        = "zip"
  source_file = "${path.module}/source/sptool_sppricing_download.py"
  output_path = "${path.module}/output/sp_sp_pricing.zip"
}

resource "aws_lambda_function" "sp_sp_pricing" {
  filename         = "${path.module}/output/sp_sp_pricing.zip"
  function_name    = "SPTool_SPPricing_Download${var.env}"
  role             = aws_iam_role.SPToolS3Lambda.arn
  handler          = "sptool_sppricing_download.lambda_handler"
  source_code_hash = data.archive_file.sp_sp_pricing_zip.output_base64sha256
  runtime          = "python3.8"
  memory_size      = "4096"
  timeout          = "150"

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.s3_bucket.id
      DATABASE    = var.pricing_db_name
    }
  }

}

resource "aws_lambda_permission" "allow_cloudwatch_sp_sp_pricing" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sp_sp_pricing.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.sp_sp_pricing_cloudwatch_rule.arn
}

resource "aws_cloudwatch_event_rule" "sp_sp_pricing_cloudwatch_rule" {
  name                = "sp_sp_pricing_lambda_trigger"
  schedule_expression = var.weekly_cron
}

resource "aws_cloudwatch_event_target" "sp_sp_pricing_lambda" {
  rule      = aws_cloudwatch_event_rule.sp_sp_pricing_cloudwatch_rule.name
  target_id = "sp_sp_pricing_lambda_target"
  arn       = aws_lambda_function.sp_sp_pricing.arn
}

