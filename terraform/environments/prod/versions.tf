# Versions minimales exigées — identiques pour staging et prod
terraform {
  required_version = ">= 1.10" # use_lockfile (verrou natif S3) n'existe qu'à partir de 1.10

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0" # toute 6.x, jamais 7.0 (évite une rupture surprise)
    }
  }
}
