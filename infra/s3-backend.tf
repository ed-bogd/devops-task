terraform {
  backend "s3" {
    bucket         = "dzenrei-tfstate-bucket"
    key            = "global/terraform.tfstate"
    region         = "eu-central-1"
    use_lockfile   = true
    encrypt        = true
  }
}