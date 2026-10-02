project     = "twinfleet"
environment = "prod"
aws_region  = "eu-west-3"

vpc_cidr            = "10.20.0.0/16"
azs                 = ["eu-west-3a", "eu-west-3b"]
public_subnet_cidrs = ["10.20.1.0/24", "10.20.2.0/24"]
app_subnet_cidrs    = ["10.20.11.0/24", "10.20.12.0/24"]
data_subnet_cidrs   = ["10.20.21.0/24", "10.20.22.0/24"]

db_instance_class          = "db.t3.micro"
db_allocated_storage       = 20
db_backup_retention_period = 1

instance_type        = "t3.micro"
asg_min_size         = 2
asg_max_size         = 4
asg_desired_capacity = 2
