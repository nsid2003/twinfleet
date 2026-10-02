module "network" {
  source = "../../modules/network"
}

module "compute" {
  source = "../../modules/compute"
}

module "data" {
  source = "../../modules/data"
}
