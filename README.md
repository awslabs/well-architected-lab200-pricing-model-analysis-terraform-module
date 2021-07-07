# aws_tf_pricing_model_analysis

You will create two pricing data sources, by using Lambda to download the AWS price list files (On Demand EC2 pricing, and Savings Plans rates from all regions) and extract the pricing components required. You can configure CloudWatch Events to periodically run these functions to ensure you have the most up to date pricing and the latest instances in your data.
It is the linked to the AWS Well Architected Lab: [LEVEL 200: PRICING MODEL ANALYSIS](https://wellarchitectedlabs.com/cost/200_labs/200_pricing_model_analysis/)
Please replacce with your region below.

## Usage

```

provider "aws" {
  region  = "eu-west-1"
}


module "aws_tf_pricing_model_analysis" {
  source = "github.com/awslabs/well-architected-lab200-pricing-model-analysis-terraform-module"
  region = "eu-west-1"
  bucket_name = "cost-unique-bucketname"
}
```

---
**NOTE**

If you wish to deploy to your linked account you will need to deploy a role to access your Organization in your Management account. See below **Deploying into linked account**.

---

## Optional Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| region | The region you wish this to be deployed into| string | `""` | yes
| bucket\_name | A bucket will be created for your files. This must be unique and start with cost | string | `""` | yes |
| pricing_db_name | Athena Database your table will be created in | string | `"pricing"` | no |
| weekly_cron | Cloudwatch cron to pull the data | string | `"cron(07 1 ? * MON *)"` | no |
| env | Environment prefix if needed| string | `""` | no 



## Prerequisites
- An AWS Account
- An Amazon QuickSight Account
- A Cost and Usage Report (CUR)
- Amazon Athena and QuickSight have been setup
- Completed the [Cost and Usage Analysis lab](https://wellarchitectedlabs.com/cost/200_labs/200_4_cost_and_usage_analysis/)
- Completed the [Cost and Usage Visualization lab](https://wellarchitectedlabs.com/cost/200_labs/200_5_cost_visualization/)
- Basic knowledge of AWS Lambda, Amazon Athena and Amazon Quicksight - 

## Permissions required

Log in as the Cost Optimization team, created in [AWS Account Setup](https://wellarchitectedlabs.com/cost/100_labs/100_1_aws_account_setup/)
Additional: Create a Lambda function with associated IAM roles, trigger it via CloudWatch



## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.
