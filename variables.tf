data "aws_caller_identity" "current" {}

variable "region" {
}

variable "pricing_db_name" {
  default = "pricing"
}

variable "bucket_name" {
}

variable "weekly_cron" {
  default = "cron(07 1 ? * MON *)"
}

variable "env" {
  default = ""
}