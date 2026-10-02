project     = "twinfleet"
environment = "staging"
aws_region  = "eu-west-3"

vpc_cidr            = "10.10.0.0/16"
azs                 = ["eu-west-3a", "eu-west-3b"]
public_subnet_cidrs = ["10.10.1.0/24", "10.10.2.0/24"]
app_subnet_cidrs    = ["10.10.11.0/24", "10.10.12.0/24"]
data_subnet_cidrs   = ["10.10.21.0/24", "10.10.22.0/24"]
