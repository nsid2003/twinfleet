terraform {
  backend "s3" {
    bucket       = "twinfleet-tfstate-370a93b2"
    key          = "prod/terraform.tfstate"
    region       = "eu-west-3"
    encrypt      = true
    use_lockfile = true
  }
}
