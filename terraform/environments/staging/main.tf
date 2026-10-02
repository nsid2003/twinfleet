# Appel des 3 modules partagés. Les inputs seront ajoutés au fil des PR
# de chaque responsable de module. AUCUN code de ressource ici : uniquement des appels.

module "network" {
  source = "../../modules/network"
}

module "compute" {
  source = "../../modules/compute"
}

module "data" {
  source = "../../modules/data"
}
