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

variable "vpc_cidr" {
  description = "Bloc CIDR du VPC"
  type        = string
}

variable "azs" {
  description = "Zones de disponibilité utilisées"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR des sous-réseaux publics (ALB, NAT Gateway)"
  type        = list(string)
}

variable "app_subnet_cidrs" {
  description = "CIDR des sous-réseaux privés applicatifs"
  type        = list(string)
}

variable "data_subnet_cidrs" {
  description = "CIDR des sous-réseaux privés de données"
  type        = list(string)
}

variable "app_port" {
  description = "Port HTTP exposé par les instances applicatives"
  type        = number
  default     = 80
}

variable "db_port" {
  description = "Port de la base de données"
  type        = number
  default     = 5432
}
