variable "aws_profile" { default = "dzenrei" }   # profile from ~/.aws/config
variable "aws_region"  { default = "eu-central-1" }

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

data "aws_caller_identity" "me" {}