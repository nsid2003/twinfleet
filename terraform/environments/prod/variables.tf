variable "project" {
  description = "Préfixe de nommage de toutes les ressources"
  type        = string
}

variable "environment" {
  description = "Nom de l'environnement (staging | prod)"
  type        = string

  validation {
    condition     = contains(["staging", "prod"], var.environment)
    error_message = "environment doit valoir staging ou prod."
  }
}

variable "aws_region" {
  description = "Région AWS de déploiement"
  type        = string
  default     = "eu-west-3"
}
