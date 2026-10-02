locals {
  name_prefix = "${var.project}-${var.environment}"
}

module "network" {
  source = "../../modules/network"

  name_prefix         = local.name_prefix
  vpc_cidr            = var.vpc_cidr
  azs                 = var.azs
  public_subnet_cidrs = var.public_subnet_cidrs
  app_subnet_cidrs    = var.app_subnet_cidrs
  data_subnet_cidrs   = var.data_subnet_cidrs
  app_port            = var.app_port
  db_port             = var.db_port
}

module "compute" {
  source = "../../modules/compute"
}

module "data" {
  source = "../../modules/data"

  name_prefix             = local.name_prefix
  data_subnet_ids         = module.network.data_subnet_ids
  db_sg_id                = module.network.db_sg_id
  db_port                 = var.db_port
  db_instance_class       = var.db_instance_class
  db_engine_version       = var.db_engine_version
  db_allocated_storage    = var.db_allocated_storage
  db_name                 = var.db_name
  db_username             = var.db_username
  backup_retention_period = var.db_backup_retention_period
  bucket_force_destroy    = var.bucket_force_destroy
}
