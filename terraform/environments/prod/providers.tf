provider "aws" {
  region = var.aws_region

  # Tags posés automatiquement sur TOUTES les ressources :
  # suivi des coûts + filtre de l'inventaire dynamique Ansible (tag Environment)
  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}
