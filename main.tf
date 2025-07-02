module "vpc" {
  source  = "app.terraform.io/HKJC-TerraformCloud-POC/vpc-vending/aws"
  version = "0.1.0"
  count  = var.vpc.create_vpcs ? 1 : 0

  account_mapping      = var.vpc
  
  ###
  # Please provide an S3 bucket arn and enable VPC flow logs
  ###
  enable_vpc_flow_logs = false
  vpc_flow_log_s3_arn = ""

  ###
  # append any tags you want to add into resources to be created in tag/value pair
  ###
  tags = {
    "hkjc:owner" = "alley-oop"
    "hkjc:environment" = "nonprod"
  }
}
variable "vpc"{}